#define pin_sensor1 D1
#define pin_sensor2 D2
#define pin_sensor3 D3
#define pin_led1 D0
#define pin_led2 D4
#define pin_led3 D8

#define CLK D7
#define DIO D6

TM1637Display display(CLK, DIO);

Ticker tk_display;
Ticker tk_read_sensor;

int sensor1=0,sensor2=0,sensor3=0;
const uint8_t P[] = {
    SEG_A | SEG_B | SEG_E | SEG_F | SEG_G            // E
};

