#ifndef SIMDJSON_BRIDGE_H
#define SIMDJSON_BRIDGE_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---- Error codes ----

typedef enum {
    SDJSON_OK = 0,
    SDJSON_ERR_PARSE = 1,
    SDJSON_ERR_PATH_NOT_FOUND = 2,
    SDJSON_ERR_SERIALIZE = 3,
    SDJSON_ERR_ALLOC = 4
} SDJsonError;

// ---- JSON value types ----

typedef enum {
    SDJSON_TYPE_OBJECT = 0,
    SDJSON_TYPE_ARRAY = 1,
    SDJSON_TYPE_STRING = 2,
    SDJSON_TYPE_NUMBER = 3,
    SDJSON_TYPE_BOOL = 4,
    SDJSON_TYPE_NULL = 5
} SDJsonType;

// ---- Result types ----

typedef struct {
    const char* data;
    size_t      length;
    SDJsonError error;
} SDJsonResult;

typedef struct {
    SDJsonType  type;
    SDJsonError error;
} SDJsonTypeResult;

typedef struct {
    SDJsonType  type;
    size_t      count;
    const char* keys;
    size_t      keys_length;
    SDJsonError error;
} SDJsonInspectResult;

/// Результат range — byte offsets внутри оригинального JSON буфера.
/// key_offset/key_length = -1/0 если ключа нет (элемент массива).
typedef struct {
    int64_t     key_offset;     // byte offset начала имени ключа (без ")
    size_t      key_length;     // длина имени ключа (без ")
    size_t      value_offset;   // byte offset начала значения
    size_t      value_length;   // длина значения в байтах
    SDJsonError error;
} SDJsonRangeResult;

// ---- API ----

SDJsonResult sdjson_extract(const char* json_data,
                            size_t json_length,
                            const char* pointer);

void sdjson_extract_many(const char* json_data,
                         size_t json_length,
                         const char** pointers,
                         size_t count,
                         SDJsonResult* out_results);

bool sdjson_exists(const char* json_data,
                   size_t json_length,
                   const char* pointer,
                   SDJsonError* out_error);

SDJsonTypeResult sdjson_type(const char* json_data,
                             size_t json_length,
                             const char* pointer);

SDJsonInspectResult sdjson_inspect(const char* json_data,
                                   size_t json_length,
                                   const char* pointer);

/// Возвращает byte range ключа и значения по JSON Pointer.
/// Для элементов массива key_offset = -1.
SDJsonRangeResult sdjson_range(const char* json_data,
                               size_t json_length,
                               const char* pointer);

void sdjson_free(const char* ptr);

#ifdef __cplusplus
}
#endif

#endif // SIMDJSON_BRIDGE_H
