#include <cmath>
#include <vector>
#include <numeric>

struct Vector3 {
    float x, y, z;
    
    float length() const {
        return std::sqrt(x * x + y * y + z * z);
    }

    Vector3 normalize() const {
        float len = length();
        if (len > 0) return {x / len, y / len, z / len};
        return {0, 0, 0};
    }
};

class SignalProcessor {
public:
    static float fast_inverse_sqrt(float number) {
        long i;
        float x2, y;
        const float threehalfs = 1.5F;

        x2 = number * 0.5F;
        y  = number;
        i  = * ( long * ) &y;
        i  = 0x5f3759df - ( i >> 1 );
        y  = * ( float * ) &i;
        y  = y * ( threehalfs - ( x2 * y * y ) );

        return y;
    }
};
