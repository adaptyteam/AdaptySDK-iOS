#include "include/SimdjsonBridge.h"
#include "simdjson.h"
#include <cstring>
#include <cstdlib>
#include <string>
#include <vector>

using namespace simdjson;

// ---- helpers ----

static inline ondemand::document* iterate_doc(
    ondemand::parser& parser,
    padded_string& padded,
    ondemand::document& doc,
    SDJsonError* out_error
) {
    auto err = parser.iterate(padded).get(doc);
    if (err) {
        *out_error = SDJSON_ERR_PARSE;
        return nullptr;
    }
    return &doc;
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

// ---- type (fast, no extra work) ----

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

// ---- inspect (type + count/keys) ----

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
        // Считаем элементы массива
        ondemand::array arr;
        auto err = val.get_array().get(arr);
        if (err) {
            result.error = SDJSON_ERR_SERIALIZE;
            return result;
        }

        size_t cnt;
        err = arr.count_elements().get(cnt);
        if (err) {
            result.error = SDJSON_ERR_SERIALIZE;
            return result;
        }

        result.count = cnt;

    } else if (jtype == ondemand::json_type::object) {
        // Собираем ключи объекта
        ondemand::object obj;
        auto err = val.get_object().get(obj);
        if (err) {
            result.error = SDJSON_ERR_SERIALIZE;
            return result;
        }

        // Первый проход — собираем ключи в вектор
        std::vector<std::string_view> key_views;
        size_t total_len = 0;

        for (auto field : obj) {
            std::string_view key;
            err = field.unescaped_key().get(key);
            if (err) {
                result.error = SDJSON_ERR_SERIALIZE;
                return result;
            }
            key_views.push_back(key);
            total_len += key.size() + 1; // +1 для \0 разделителя
        }

        result.count = key_views.size();

        if (result.count > 0) {
            // Собираем в один буфер: key1\0key2\0key3\0
            char* buf = (char*)malloc(total_len);
            if (!buf) {
                result.error = SDJSON_ERR_ALLOC;
                return result;
            }

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
    // Для scalar типов: count = 0, keys = NULL — ничего дополнительного

    return result;
}

// ---- free ----

void sdjson_free(const char* ptr) {
    free((void*)ptr);
}

} // extern "C"
