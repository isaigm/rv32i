// La dirección como macro -> GCC la materializa con lui+addi inline
#define LEDS (*(volatile unsigned int *)0x1000)

void delay(void) {
    for (volatile int i = 0; i < 8000000; i++) {
    }
}

int main(void) {
    while (1) {
        LEDS = 0xFFFF;   // encender
        delay();
        LEDS = 0x0000;   // apagar
        delay();
    }
}
