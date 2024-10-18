import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting the test...")

    # Set up the clock with a period of 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)  # Hold reset low for 5 cycles
    dut.rst_n.value = 1

    # Set the initial input values
    dut.a.value = 13
    dut.b.value = 10

    # Wait for a few clock cycles to observe the output
    await ClockCycles(dut.clk, 10)

    # Check the expected sum and carry out
    dut._log.info(f"Initial Test: sum={dut.sum.value}, carry_out={dut.carry_out.value}")
    assert dut.sum.value == 7, f"Initial test failed: expected sum=7, got {dut.sum.value}"
    assert dut.carry_out.value == 1, f"Initial test failed: expected carry_out=1, got {dut.carry_out.value}"

    # Random testing for 1000 cases
    for i in range(1000):
        a = random.randint(0, 15)  # 4-bit random value
        b = random.randint(0, 15)  # 4-bit random value

        # Apply random inputs
        dut.a.value = a
        dut.b.value = b

        # Wait for the output to stabilize
        await ClockCycles(dut.clk, 10)

        # Expected values
        expected_sum = (a + b) & 0xF  # Sum is the lower 4 bits
        expected_carry_out = (a + b) >> 4  # Carry out is the 5th bit

        # Log the results
        dut._log.info(f"Test {i+1}: a={a}, b={b}, sum={dut.sum.value}, carry_out={dut.carry_out.value}")

        # Assertions for sum and carry
        assert dut.sum.value == expected_sum, f"Test {i+1} failed: a={a}, b={b}, expected sum={expected_sum}, got {dut.sum.value}"
        assert dut.carry_out.value == expected_carry_out, f"Test {i+1} failed: a={a}, b={b}, expected carry_out={expected_carry_out}, got {dut.carry_out.value}"

    dut._log.info("All tests passed successfully!")
