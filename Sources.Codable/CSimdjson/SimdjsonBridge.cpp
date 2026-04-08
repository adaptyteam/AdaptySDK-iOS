#include "include/SimdjsonBridge.h"
#include "simdjson.h"
#include <cstring>
#include <cstdlib>
#include <string>
#include <vector>

using namespace simdjson;

// ---- helpers ----

static inline bool iterate_doc(
    ondemand::parser& parser,
    padded_string& padded,
    ondemand::document& doc,
    SDJsonError* out_error
) {
    auto err = parser.iterate(padded).get(doc);
    if (err) {
        *out_error = SDJSON_ERR_PARSE;
        return false;
    }
    return true;
}

static inline bool navigate(
    ondemand::document& doc,
    const char* pointer,
    ondemand::value& val,
    SDJsonError* out_error
) {
    auto err = doc.at_pointer(pointer).get(val);
    if (err) {
        *out_error = SDJSON_ERR_PATH_NOT_FOUND;
        return false;
    }
    return true;
}

static inline bool get_type(
    ondemand::value& val,
    ondemand::json_type& jtype,
    SDJsonError* out_error
) {
    auto err = val.type().get(jtype);
    if (err) {
        *out_error = SDJSON_ERR_SERIALIZE;
        return false;
    }
    return true;
}

static inline SDJsonType map_type(ondemand::json_type jtype) {
    switch (jtype) {
        case ondemand::json_type::object:  return SDJSON_TYPE_OBJECT;
        case ondemand::json_type::array:   return SDJSON_TYPE_ARRAY;
        case ondemand::json_type::string:  return SDJSON_TYPE_STRING;
        case ondemand::json_type::number:  return SDJSON_TYPE_NUMBER;
        case ondemand::json_type::boolean: return SDJSON_TYPE_BOOL;
        case ondemand::json_type::null:    return SDJSON_TYPE_NULL;
    }
    return SDJSON_TYPE_NULL;
}

/// Разбивает JSON Pointer на сегменты.
/// "/placements/onboarding/variations/0" → ["placements", "onboarding", "variations", "0"]
static std::vector<std::string> split_pointer(const char* pointer) {
    std::vector<std::string> segments;
    if (!pointer || pointer[0] == '\0') return segments;

    // Пропускаем начальный /
    const char* p = pointer;
    if (*p == '/') p++;

    std::string current;
    while (*p) {
        if (*p == '/') {
            segments.push_back(current);
            current.clear();
        } else if (*p == '~') {
            // RFC 6901 unescape: ~1 → /, ~0 → ~
            p++;
            if (*p == '1') current += '/';
            else if (*p == '0') current += '~';
        } else {
            current += *p;
        }
        p++;
    }
    segments.push_back(current);
    return segments;
}

/// Проверяет, является ли строка числовым индексом массива
static bool is_array_index(const std::string& s) {
    if (s.empty()) return false;
    for (char c : s) {
        if (c < '0' || c > '9') return false;
    }
    return true;
}

// ---- extract ----

static SDJsonResult extract_at_pointer(ondemand::document& doc, const char* pointer) {
    SDJsonResult result;
    result.data = nullptr;
    result.length = 0;
    result.error = SDJSON_OK;

    ondemand::value val;
    auto err = doc.at_pointer(pointer).get(val);
    if (err) {
        result.error = SDJSON_ERR_PATH_NOT_FOUND;
        return result;
    }

    std::string_view raw;
    err = to_json_string(val).get(raw);
    if (err) {
        result.error = SDJSON_ERR_SERIALIZE;
        return result;
    }

    char* buf = (char*)malloc(raw.size());
    if (!buf) {
        result.error = SDJSON_ERR_ALLOC;
        return result;
    }

    memcpy(buf, raw.data(), raw.size());
    result.data = buf;
    result.length = raw.size();
    return result;
}

extern "C" {

SDJsonResult sdjson_extract(const char* json_data,
                            size_t json_length,
                            const char* pointer) {
    SDJsonResult result;
    result.data = nullptr;
    result.length = 0;
    result.error = SDJSON_OK;

    padded_string padded(json_data, json_length);
    ondemand::parser parser;
    ondemand::document doc;

    if (!iterate_doc(parser, padded, doc, &result.error)) return result;
    return extract_at_pointer(doc, pointer);
}

void sdjson_extract_many(const char* json_data,
                         size_t json_length,
                         const char** pointers,
                         size_t count,
                         SDJsonResult* out_results) {
    padded_string padded(json_data, json_length);
    ondemand::parser parser;

    for (size_t i = 0; i < count; i++) {
        out_results[i].data = nullptr;
        out_results[i].length = 0;
        out_results[i].error = SDJSON_OK;

        ondemand::document doc;
        auto err = parser.iterate(padded).get(doc);
        if (err) {
            out_results[i].error = SDJSON_ERR_PARSE;
            continue;
        }

        out_results[i] = extract_at_pointer(doc, pointers[i]);
    }
}

// ---- exists ----

bool sdjson_exists(const char* json_data,
                   size_t json_length,
                   const char* pointer,
                   SDJsonError* out_error) {
    *out_error = SDJSON_OK;

    padded_string padded(json_data, json_length);
    ondemand::parser parser;
    ondemand::document doc;

    if (!iterate_doc(parser, padded, doc, out_error)) return false;

    ondemand::value val;
    return !doc.at_pointer(pointer).get(val);
}

// ---- type (fast) ----

SDJsonTypeResult sdjson_type(const char* json_data,
                             size_t json_length,
                             const char* pointer) {
    SDJsonTypeResult result;
    result.type = SDJSON_TYPE_NULL;
    result.error = SDJSON_OK;

    padded_string padded(json_data, json_length);
    ondemand::parser parser;
    ondemand::document doc;

    if (!iterate_doc(parser, padded, doc, &result.error)) return result;

    ondemand::value val;
    if (!navigate(doc, pointer, val, &result.error)) return result;

    ondemand::json_type jtype;
    if (!get_type(val, jtype, &result.error)) return result;

    result.type = map_type(jtype);
    return result;
}

// ---- inspect ----

SDJsonInspectResult sdjson_inspect(const char* json_data,
                                   size_t json_length,
                                   const char* pointer) {
    SDJsonInspectResult result;
    result.type = SDJSON_TYPE_NULL;
    result.count = 0;
    result.keys = nullptr;
    result.keys_length = 0;
    result.error = SDJSON_OK;

    padded_string padded(json_data, json_length);
    ondemand::parser parser;
    ondemand::document doc;

    if (!iterate_doc(parser, padded, doc, &result.error)) return result;

    ondemand::value val;
    if (!navigate(doc, pointer, val, &result.error)) return result;

    ondemand::json_type jtype;
    if (!get_type(val, jtype, &result.error)) return result;

    result.type = map_type(jtype);

    if (jtype == ondemand::json_type::array) {
        ondemand::array arr;
        auto err = val.get_array().get(arr);
        if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }

        size_t cnt;
        err = arr.count_elements().get(cnt);
        if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }
        result.count = cnt;

    } else if (jtype == ondemand::json_type::object) {
        ondemand::object obj;
        auto err = val.get_object().get(obj);
        if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }

        std::vector<std::string_view> key_views;
        size_t total_len = 0;

        for (auto field : obj) {
            std::string_view key;
            err = field.unescaped_key().get(key);
            if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }
            key_views.push_back(key);
            total_len += key.size() + 1;
        }

        result.count = key_views.size();

        if (result.count > 0) {
            char* buf = (char*)malloc(total_len);
            if (!buf) { result.error = SDJSON_ERR_ALLOC; return result; }

            size_t offset = 0;
            for (auto& kv : key_views) {
                memcpy(buf + offset, kv.data(), kv.size());
                offset += kv.size();
                buf[offset] = '\0';
                offset++;
            }

            result.keys = buf;
            result.keys_length = total_len;
        }
    }

    return result;
}

// ---- range ----

SDJsonRangeResult sdjson_range(const char* json_data,
                               size_t json_length,
                               const char* pointer) {
    SDJsonRangeResult result;
    result.key_offset = -1;
    result.key_length = 0;
    result.value_offset = 0;
    result.value_length = 0;
    result.error = SDJSON_OK;

    padded_string padded(json_data, json_length);
    ondemand::parser parser;
    ondemand::document doc;

    if (!iterate_doc(parser, padded, doc, &result.error)) return result;

    auto segments = split_pointer(pointer);
    if (segments.empty()) {
        result.error = SDJSON_ERR_PATH_NOT_FOUND;
        return result;
    }

    const char* buf_start = padded.data();
    std::string last_segment = segments.back();
    bool last_is_array_index = is_array_index(last_segment);

    // Строим parent pointer (всё кроме последнего сегмента)
    std::string parent_pointer;
    for (size_t i = 0; i < segments.size() - 1; i++) {
        parent_pointer += "/" + segments[i];
    }

    if (last_is_array_index) {
        // Элемент массива — ключа нет
        // Навигируем по полному пути, берём позицию значения
        ondemand::value val;
        if (!navigate(doc, pointer, val, &result.error)) return result;

        // raw_json_token() указывает на начало значения внутри буфера
        std::string_view raw_token = val.raw_json_token();

        // Для получения полной длины значения используем to_json_string
        // Нужен rewind — делаем заново
        doc.rewind();
        ondemand::value val2;
        if (!navigate(doc, pointer, val2, &result.error)) return result;

        std::string_view full_value;
        auto err2 = simdjson::to_json_string(val2).get(full_value);
        if (err2) { result.error = SDJSON_ERR_SERIALIZE; return result; }

        result.key_offset = -1;
        result.key_length = 0;
        result.value_offset = raw_token.data() - buf_start;
        result.value_length = full_value.size();

    } else {
        // Поле объекта — нужно найти позицию ключа и значения
        // Навигируем к родительскому объекту
        ondemand::object parent_obj;

        if (parent_pointer.empty()) {
            auto err = doc.get_object().get(parent_obj);
            if (err) { result.error = SDJSON_ERR_PARSE; return result; }
        } else {
            ondemand::value parent_val;
            if (!navigate(doc, parent_pointer.c_str(), parent_val, &result.error))
                return result;
            auto err = parent_val.get_object().get(parent_obj);
            if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }
        }

        // Итерируем по полям родителя, ищем нужный ключ.
        // ВАЖНО: в simdjson on-demand нельзя вызывать и key() и
        // unescaped_key() на одном field — второй вызов вернёт невалидные
        // данные. Поэтому используем только key() для позиции и сравнения.
        bool found = false;
        for (auto field : parent_obj) {
            ondemand::raw_json_string raw_key;
            auto err = field.key().get(raw_key);
            if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }

            if (!raw_key.unsafe_is_equal(last_segment.c_str())) continue;

            // Нашли! raw() указывает ПОСЛЕ открывающей кавычки.
            const char* key_raw_ptr = raw_key.raw();

            // Находим закрывающую кавычку ключа, учитывая escape-последовательности
            const char* p = key_raw_ptr;
            while (*p != '"') {
                if (*p == '\\') p++; // пропускаем escaped символ
                p++;
            }
            size_t raw_key_len = p - key_raw_ptr;

            result.key_offset = key_raw_ptr - buf_start;
            result.key_length = raw_key_len;

            // Получаем позицию значения
            ondemand::value field_val;
            err = field.value().get(field_val);
            if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }

            std::string_view val_token = field_val.raw_json_token();
            result.value_offset = val_token.data() - buf_start;

            // to_json_string consume-ит value, поэтому rewind + at_pointer
            doc.rewind();

            ondemand::value full_val;
            err = doc.at_pointer(pointer).get(full_val);
            if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }

            std::string_view full_json;
            err = to_json_string(full_val).get(full_json);
            if (err) { result.error = SDJSON_ERR_SERIALIZE; return result; }

            result.value_length = full_json.size();
            found = true;
            break;
        }

        if (!found) {
            result.error = SDJSON_ERR_PATH_NOT_FOUND;
        }
    }

    return result;
}

// ---- free ----

void sdjson_free(const char* ptr) {
    free((void*)ptr);
}

} // extern "C"
