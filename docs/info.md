<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# Ternary-158 Accelerator Engine

## How it works
This project is a high-efficiency hardware processing core designed natively for 1.58-bit ternary AI architectures (such as BitNet b1.58 and Fully Ternary Vision Transformers). Traditional AI chips require expensive, power-hungry multiplication blocks. This design completely eliminates multipliers. By restricting model weights strictly to ternary states (-1, 0, +1), it replaces multiplication with simple multiplexer-driven 32-bit integer addition and subtraction gates. 

It takes an 8-bit streaming activation input (like grayscale image pixels from an ESP32 camera sensor), performs a sign-extension check, and calculates a running matrix calculation layer without a single floating-point math circuit.

## How to test
To verify the ternary arithmetic execution:
1. Provide a stable clock source to `clk` and toggle the active-low reset pin `rst_n` to 0 to safely clear the internal registers.
2. Send an 8-bit input pattern to the dedicated input bus `ui_in` to represent your streaming data activation.
3. Configure the first two bidirectional pins `uio_in[1:0]` to select your target weight state:
   - Set to `2'b01` to test addition (+1 weight)
   - Set to `2'b10` to test subtraction (-1 weight)
   - Set to `2'b00` or `2'b11` to test the pass-through state (0 weight)
4. Monitor the calculated accumulation output on the output bus `uo_out`, which displays the most significant bits of your calculation result.

## External hardware
This chip core can act as a high-speed AI arithmetic co-processor. It is designed to be wired directly to an ESP32 microcontroller using standard Serial Peripheral Interface (SPI) links or parallel GPIO buses. The ESP32 acts as the host system (handling camera inputs or Wi-Fi data tokens), while this ASIC core handles the deep-learning matrix math.

