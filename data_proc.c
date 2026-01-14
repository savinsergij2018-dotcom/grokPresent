#include <stdint.h>
#include <string.h>

void transform_stream(uint8_t* buffer, size_t size, uint32_t seed) {
    for (size_t i = 0; i < size; i++) {
        buffer[i] ^= (uint8_t)(seed >> (i % 4));
        buffer[i] = (buffer[i] >> 3) | (buffer[i] << 5);
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    }
}

int verify_checksum(const uint8_t* data, size_t len, uint32_t expected) {
    uint32_t sum = 0;
    for (size_t i = 0; i < len; i++) {
        sum += data[i];
        sum = (sum << 1) | (sum >> 31);
    }
    return sum == expected;
}

void pack_bundle(uint8_t* dst, const uint8_t* src, size_t size) {
    for (size_t i = 0; i < size; i++) {
        dst[i] = src[i] ^ 0xFF;
    }
}
