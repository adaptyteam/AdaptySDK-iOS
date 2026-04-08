#ifndef SIMDJSON_BRIDGE_H
#define SIMDJSON_BRIDGE_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Коды ошибок
typedef enum {
    SDJSON_OK = 0,
    SDJSON_ERR_PARSE = 1,
    SDJSON_ERR_PATH_NOT_FOUND = 2,
    SDJSON_ERR_SERIALIZE = 3,
    SDJSON_ERR_ALLOC = 4
} SDJsonError;

/// Результат извлечения
typedef struct {
    const char* data;       // JSON-фрагмент (caller должен освободить через sdjson_free)
    size_t      length;     // длина в байтах
    SDJsonError error;      // код ошибки
} SDJsonResult;

/// Извлекает JSON-фрагмент по JSON Pointer пути.
/// `json_data`   — указатель на полный JSON (не обязательно null-terminated)
/// `json_length` — длина JSON в байтах
/// `pointer`     — JSON Pointer, напр. "/placements/onboarding"
///
/// Возвращает SDJsonResult. При успехе data != NULL и error == SDJSON_OK.
/// Caller ОБЯЗАН вызвать sdjson_free(result.data) после использования.
SDJsonResult sdjson_extract(const char* json_data,
                            size_t json_length,
                            const char* pointer);

/// Извлекает несколько путей за один проход.
/// `pointers`     — массив JSON Pointer строк
/// `count`        — количество указателей
/// `out_results`  — массив SDJsonResult размером count (caller аллоцирует)
///
/// Для каждого пути заполняет out_results[i].
/// Caller должен вызвать sdjson_free для каждого успешного результата.
void sdjson_extract_many(const char* json_data,
                         size_t json_length,
                         const char** pointers,
                         size_t count,
                         SDJsonResult* out_results);

/// Освобождает память, выделенную sdjson_extract.
void sdjson_free(const char* ptr);

#ifdef __cplusplus
}
#endif

#endif // SIMDJSON_BRIDGE_H

