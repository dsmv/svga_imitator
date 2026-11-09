#!/usr/bin/env python3

#
# Standalone LiteX SoC for this lab.
#
# Same role as `litex_soc_gen`: a CPU, memories and peripherals exported as one
# Verilog module (clk/rst, UART) that is instantiated from the surrounding
# SystemVerilog. The four LEDs are a GPIO output: firmware writes the `leds_out`
# CSR and the `led[3:0]` port follows that value.
#
# `--sim` runs this same SoC in Verilator. The console UART is the simulation
# stream (`serial2console`), and the system clock is 1 MHz so the BIOS prompt
# appears in reasonable time.
#

import os

from migen import *

from litex.build.generic_platform import *

from litex.soc.cores.gpio import GPIOOut
from litex.soc.integration.soc import *
from litex.soc.integration.builder import *
from litex.soc.interconnect import wishbone
from litex.soc.interconnect import axi

# Defaults match the previous `litex_soc_gen` invocation in _2_gen.sh.
SOC_NAME                  = "litex_soc_m1"
SYS_CLK_FREQ              = int(65e6)
CPU_TYPE                  = "picorv32"
CPU_VARIANT               = "minimal"
#BUS_STANDARD              = "axi-lite"
BUS_STANDARD              = "wishbone"
INTEGRATED_MAIN_RAM_SIZE  = 0x1000
NLEDS                     = 4
SIM_CLK_FREQ              = int(1e6)

# IOs/Interfaces -----------------------------------------------------------------------------------

def get_common_ios():
    return [
        ("clk", 0, Pins(1)),
        ("rst", 0, Pins(1)),
    ]

def get_uart_ios():
    return [
        ("uart", 0,
            Subsignal("tx", Pins(1)),
            Subsignal("rx", Pins(1)),
        )
    ]

def get_serial_ios():
    # Stream UART used by the Verilator serial2console module.
    return [
        ("serial", 0,
            Subsignal("source_valid", Pins(1)),
            Subsignal("source_ready", Pins(1)),
            Subsignal("source_data",  Pins(8)),
            Subsignal("sink_valid",   Pins(1)),
            Subsignal("sink_ready",   Pins(1)),
            Subsignal("sink_data",    Pins(8)),
        )
    ]

def get_debug_ios(debug_width=8):
    return [
        ("debug", 0, Pins(debug_width)),
    ]

def get_led_ios(nleds=NLEDS):
    return [
        ("led", 0, Pins(nleds)),
    ]

# Platform -----------------------------------------------------------------------------------------

class Platform(GenericPlatform):
    def build(self, fragment, build_dir, build_name, **kwargs):
        os.makedirs(build_dir, exist_ok=True)
        os.chdir(build_dir)
        conv_output = self.get_verilog(fragment, name=build_name)
        conv_output.write(f"{build_name}.v")

# SoC ----------------------------------------------------------------------------------------------

class LiteXSoCM1(SoCMini):
    def __init__(self, name=SOC_NAME, sys_clk_freq=SYS_CLK_FREQ, nleds=NLEDS, sim=False, **kwargs):
        if sim:
            from litex.build.sim import SimPlatform
            # Verilator's LiteX harness always elaborates a top module named "sim".
            platform = SimPlatform("SIM", [("sys_clk", 0, Pins(1))], name="sim")
            platform.add_extension(get_serial_ios())
            self.submodules.crg = CRG(clk=platform.request("sys_clk"))
            kwargs["uart_name"] = "sim"
        else:
            platform = Platform(device="", io=get_common_ios())
            platform.name = name
            platform.add_extension(get_uart_ios())
            self.submodules.crg = CRG(
                clk = platform.request("clk"),
                rst = platform.request("rst"),
            )
            if kwargs.get("uart_name", "serial") == "serial":
                kwargs["uart_name"] = "uart"
        platform.add_extension(get_led_ios(nleds))

        SoCCore.__init__(self, platform, clk_freq=sys_clk_freq, ident=f"LiteX standalone SoC - {name}", **kwargs)

        # CPU-controlled LEDs. CSR name: leds_out, one bit per LED.
        self.leds = GPIOOut(pads=platform.request("led"))

        # MMAP slave: external logic reaches the SoC memories and CSRs.
        # s_bus = {
        #     "wishbone": wishbone.Interface(),
        #     "axi-lite": axi.AXILiteInterface(),
        # }[kwargs["bus_standard"]]
        # self.bus.add_master(name="mmap_s", master=s_bus)
        # platform.add_extension(s_bus.get_ios("mmap_s"))
        # self.comb += s_bus.connect_to_pads(platform.request("mmap_s"), mode="slave")

        # MMAP master: the CPU reaches external logic through this window.
        # m_bus = {
        #     "wishbone": wishbone.Interface(),
        #     "axi-lite": axi.AXILiteInterface(),
        # }[kwargs["bus_standard"]]
        # self.bus.add_slave(name="mmap_m", slave=m_bus, region=SoCRegion(origin=0xa000_0000, size=0x1000_0000, cached=False))
        # platform.add_extension(m_bus.get_ios("mmap_m"))
        # self.comb += m_bus.connect_to_pads(platform.request("mmap_m"), mode="master")

        platform.add_extension(get_debug_ios())
        debug_pads = platform.request("debug")
        self.comb += [
            debug_pads[0].eq(0),
            debug_pads[1].eq(1),
        ]

# Build --------------------------------------------------------------------------------------------

def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(description="LiteX SoC litex_soc_m1 with 4 CPU-controlled LEDs.")
    target_group = parser.add_argument_group(title="Generator options")
    target_group.add_argument("--name",            default=SOC_NAME,     help="SoC name.")
    target_group.add_argument("--build",           action="store_true",  help="Generate the Verilog and the software support.")
    target_group.add_argument("--sim",             action="store_true",  help="Build and run this SoC in Verilator.")
    target_group.add_argument("--non-interactive", action="store_true",  help="Run the simulation without reading the terminal.")
    target_group.add_argument("--sys-clk-freq",    default=SYS_CLK_FREQ, type=float, help="System clock frequency.")
    target_group.add_argument("--nleds",           default=NLEDS,        type=int,   help="Number of LED outputs.")
    builder_args(parser)
    soc_core_args(parser)
    parser.set_defaults(
        cpu_type                 = CPU_TYPE,
        cpu_variant              = CPU_VARIANT,
        bus_standard             = BUS_STANDARD,
        integrated_main_ram_size = INTEGRATED_MAIN_RAM_SIZE,
    )
    args = parser.parse_args()

    sys_clk_freq = int(float(args.sys_clk_freq))
    if args.sim and sys_clk_freq == SYS_CLK_FREQ:
        sys_clk_freq = SIM_CLK_FREQ

    soc = LiteXSoCM1(
        name         = args.name,
        sys_clk_freq = sys_clk_freq,
        nleds        = args.nleds,
        sim          = args.sim,
        **soc_core_argdict(args)
    )

    builder_kwargs = builder_argdict(args)
    # Keep the exported Verilog in build/litex_soc_m1.
    if args.sim and not builder_kwargs.get("output_dir"):
        builder_kwargs["output_dir"] = os.path.join("build", args.name + "_sim")
    builder = Builder(soc, **builder_kwargs)
    if args.sim:
        from litex.build.sim.config import SimConfig
        sim_config = SimConfig()
        sim_config.add_clocker("sys_clk", freq_hz=sys_clk_freq)
        sim_config.add_module("serial2console", "serial")
        builder.build(
            run         = True,
            sim_config  = sim_config,
            interactive = not args.non_interactive,
        )
    else:
        builder.build(build_name=args.name, run=args.build)

if __name__ == "__main__":
    main()
