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

/// Результат inspect для object/array.
/// Для object: keys содержит \0-separated ключи, count = количество ключей.
/// Для array:  keys = NULL, count = количество элементов.
/// Для scalar: keys = NULL, count = 0.
/// Caller ОБЯЗАН вызвать sdjson_free(result.keys) если keys != NULL.
typedef struct {
    SDJsonType  type;
    size_t      count;
    const char* keys;        // \0-separated строка ключей (только для object)
    size_t      keys_length; // полная длина keys буфера в байтах
    SDJsonError error;
} SDJsonInspectResult;

// ---- API ----

/// Извлекает JSON-фрагмент по JSON Pointer пути.
SDJsonResult sdjson_extract(const char* json_data,
                            size_t json_length,
                            const char* pointer);

/// Извлекает несколько путей за один вызов.
void sdjson_extract_many(const char* json_data,
                         size_t json_length,
                         const char** pointers,
                         size_t count,
                         SDJsonResult* out_results);

/// Проверяет существование значения по JSON Pointer пути.
bool sdjson_exists(const char* json_data,
                   size_t json_length,
                   const char* pointer,
                   SDJsonError* out_error);

/// Возвращает тип значения по JSON Pointer пути. Быстрый — без доп. работы.
SDJsonTypeResult sdjson_type(const char* json_data,
                             size_t json_length,
                             const char* pointer);

/// Возвращает тип + дополнительную информацию:
/// - object → тип + количество ключей + имена ключей
/// - array  → тип + количество элементов
/// - scalar → тип
SDJsonInspectResult sdjson_inspect(const char* json_data,
                                   size_t json_length,
                                   const char* pointer);

/// Освобождает память.
void sdjson_free(const char* ptr);

#ifdef __cplusplus
}
#endif

#endif // SIMDJSON_BRIDGE_H

