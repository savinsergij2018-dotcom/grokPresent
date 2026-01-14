#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

class DataEncryptor {
public:
    static std::string xor_cipher(const std::string& data, const std::string& key) {
        std::string result = data;
        for (size_t i = 0; i < data.size(); ++i) {
            result[i] = data[i] ^ key[i % key.size()];
        }
        return result;
    }

    static std::vector<uint8_t> transform(const std::vector<uint8_t>& input) {
        std::vector<uint8_t> output = input;
        std::reverse(output.begin(), output.end());
        for (auto& b : output) {
            b = (b << 4) | (b >> 4);
        }
        return output;
    }
};

int main() {
    std::string secret = "SensitiveData";
    std::string key = "42";
    std::string encrypted = DataEncryptor::xor_cipher(secret, key);
    std::cout << encrypted << std::endl;
    return 0;
}
