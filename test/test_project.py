import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_basic(dut):
    """Test basic ternary accelerator functionality"""
    
    # Create a clock
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())
    
    # Reset the design
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    
    # Test weight = 0 (no-op)
    dut.ui_in.value = 0x42  # Test value
    dut.uio_in.value = 0b00  # weight = 0
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0, f"Expected 0, got {dut.uo_out.value}"
    
    # Test weight = +1 (add)
    dut.uio_in.value = 0b01  # weight = +1
    await ClockCycles(dut.clk, 1)
    
    # Test weight = -1 (subtract)
    dut.uio_in.value = 0b10  # weight = -1
    await ClockCycles(dut.clk, 1)
