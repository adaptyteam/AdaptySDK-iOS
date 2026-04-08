#include "include/SimdjsonBridge.h"
#include "simdjson.h"
#include <cstring>
#include <cstdlib>
#include <string>

using namespace simdjson;

// Вспомогательная функция: извлечь raw JSON и скопировать в malloc-буфер
static SDJsonResult extract_at_pointer(ondemand::document& doc, const char* pointer) {
    SDJsonResult result;
    result.data = nullptr;
    result.length = 0;
    result.error = SDJSON_OK;

    // at_pointer навигирует к нужному значению без парсинга всего дерева
    ondemand::value val;
    auto err = doc.at_pointer(pointer).get(val);
    if (err) {
        result.error = SDJSON_ERR_PATH_NOT_FOUND;
        return result;
    }

    // raw_json() возвращает string_view на исходный буфер — zero-copy
    std::string_view raw;
    err = to_json_string(val).get(raw);
    if (err) {
        result.error = SDJSON_ERR_SERIALIZE;
        return result;
    }

    // Копируем в отдельный буфер, т.к. padded_string может быть освобождён
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

    // padded_string_view требует SIMDJSON_PADDING байт после данных.
    // Для безопасности копируем в padded_string.
    padded_string padded(json_data, json_length);

    ondemand::parser parser;
    ondemand::document doc;

    auto err = parser.iterate(padded).get(doc);
    if (err) {
        result.error = SDJSON_ERR_PARSE;
        return result;
    }

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

        // at_pointer вызывает rewind, поэтому можно вызывать многократно
        ondemand::document doc;
        auto err = parser.iterate(padded).get(doc);
        if (err) {
            out_results[i].error = SDJSON_ERR_PARSE;
            continue;
        }

        out_results[i] = extract_at_pointer(doc, pointers[i]);
    }
}

void sdjson_free(const char* ptr) {
    free((void*)ptr);
}

} // extern "C"



