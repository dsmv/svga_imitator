
# 98_1_litex_demo

Привет показывает путь установки процессра picorv32 как компонента 

Используется система litex: https://github.com/enjoy-digital/litex

Порядок сборки примера:
* Перейти в каталог litex
* Выполнить последовательно команды:
    * _2_init.sh    - инициализация системы
    * Извлечь из архива `build/litex_soc_m1/bundles/litex-build-input-XXXXXXX.tar.gz` файлы *.v в каталог `litex/rtl`
    * _3_gen_program.sh - компиляция demo примера программы на C++
    * _4_write_program_to_rom.sh    - замена BIOS на программу demo, уменьшение размеров ROM и SRAM
    * _5_sim_program.sh - запуск симуляции с программой demo
* Вернуться в каталог примера
    * 03_synthesize_for_fpga.bash - сборка примера и загрузка на плату

## Каталог litex

* _1_run_litex_sim.sh   - запуск примера litex с процессором и симуляцией работы BIOS
* _2_init.sh    - инициализация системы с процессором и программой BIOS
* _3_gen_program.sh - компиляция demo примера программы на C++
* _4_write_program_to_rom.sh    - замена BIOS на программу demo, уменьшение размеров ROM и SRAM
* _5_sim_program.sh - запуск симуляции с программой demo
* litex_soc_m1.py   - описание системы
* rtl   - каталог с используемыми компонентами litex
* build - каталог сборки


### _1_run_litex_sim.sh

Команда:
```
    litex_sim --cpu-type=picorv32 --cpu-variant=minimal
```

Команда запускает симуляцию выбранного процессора, в данном случае `picorv32` с программой BIOS.

Результат. Выход через Ctrl+C

```
[qemu_axi] loaded (0x5635529bdef0)
[swdremote] loaded (0x5635529bdef0)
[jtagremote] loaded (0x5635529bdef0)
[gmii_ethernet] loaded (0x5635529bdef0)
[spdeeprom] loaded (addr = 0x0)
[clocker] loaded
[serial2tcp] loaded (0x5635529bdef0)
[serial2console] loaded (0x5635529bdef0)
[ethernet] loaded (0x5635529bdef0)
[xgmii_ethernet] loaded (0x5635529bdef0)
MDEBUG: Save time: -1, load_time: 0
[clocker] sys_clk: freq_hz=1000000, phase_deg=0

        __   _ __      _  __
       / /  (_) /____ | |/_/
      / /__/ / __/ -_)>  <
     /____/_/\__/\__/_/|_|
   Build your hardware, easily!

 (c) Copyright 2012-2026 Enjoy-Digital
 (c) Copyright 2007-2015 M-Labs

 BIOS built on Nov  8 2026 23:07:45
 BIOS CRC passed (a3f9fafa)

 LiteX git sha1: c12fae344

--================ SoC =================--
CPU:            PicoRV32 @ 1MHz
BUS:            wishbone 32-bit data/32-bit addr
CSR:            32-bit data big ordering
ROM:            128.0KiB
SRAM:           8.0KiB

--================ Boot ================--
Booting from serial...
Press Q or ESC to abort boot completely.
sL5DdSMmkekro
Timeout
No boot medium found

--============== Console ===============--

litex> help

LiteX BIOS, available commands:

flush_cpu_dcache         - Flush CPU data cache
crc                      - Compute CRC32 of a part of the address space
ident                    - Identifier of the system
help                     - Print this help

serialboot               - Boot from Serial (SFL)
reboot                   - Reboot
boot                     - Boot from Memory

mem_cmp                  - Compare memory content
mem_speed                - Test memory speed
mem_test                 - Test memory access
mem_copy                 - Copy address space
mem_write                - Write address space
mem_read                 - Read address space
mem_list                 - List available memory regions

litex>     

```


### _2_init.sh

```
    python3 litex_soc_m1.py --build   --build-bundle \
    --bios-console=lite --libc-mode=minimal
```

Команда запускает сборку системы которая описана в файле `litex_soc_m1.py`
Ключ `--build-bundle` указывает на требование формирования архива `build/litex_soc_m1/bundles/litex-build-input-9a9329085f5f.tar.gz` с компонентами litex которые используются для формирования `build/litex_soc_m1/gateware/litex_soc_m1.v`

Название архива включает в себя случайное число, при нескольких вызовах _2_init.sh будут сформированы несколько архивов. Внутри архива надо найти файлы *.v и извлечь их в каталог `litex/rtl`

### _3_gen_program.sh

```
litex_bare_metal_demo --build-path=build/litex_soc_m1 --mem=rom \
--runtime-mem=sram 
```

Команда формирует демонстрационный пример для выбранной конфигурации.
В состав примера входят "Hello, world!" и управление светодиодами.

### _4_write_program_to_rom.sh

```
python3 litex_soc_m1.py --build \
    --integrated-main-ram-size=0 \
    --integrated-rom-size=0x1000 \
    --integrated-rom-init=demo.bin
```

Команда записывает demo пример в память ROM и уменьшает размер памяти ROM

В результате в каталоге `litex/build/litex_soc_m1/gateware` будут сформированы файлы *.init с содержимым памяти ROM и компонент `litex_soc_m1.v` с реализацией заданной системы.

###  _5_sim_program.sh

```
python3 litex_soc_m1.py --sim \
    --integrated-main-ram-size=0 \
    --integrated-rom-size=0x1000 \
    --integrated-rom-init=demo.bin
```

Команда запускает симуляцию системы с программой demo.
Программа demo запускает терминал в котором можно выбрать команды для выполнения.
Выход по Ctrl+C

Результат:

```
[qemu_axi] loaded (0x62b44bed2ef0)
[swdremote] loaded (0x62b44bed2ef0)
[jtagremote] loaded (0x62b44bed2ef0)
[gmii_ethernet] loaded (0x62b44bed2ef0)
[spdeeprom] loaded (addr = 0x0)
[clocker] loaded
[serial2tcp] loaded (0x62b44bed2ef0)
[serial2console] loaded (0x62b44bed2ef0)
[ethernet] loaded (0x62b44bed2ef0)
[xgmii_ethernet] loaded (0x62b44bed2ef0)
MDEBUG: Save time: -1, load_time: 0
[clocker] sys_clk: freq_hz=1000000, phase_deg=0

LiteX minimal demo app built Nov  9 2026 00:39:22

Available commands:
help               - Show this command
reboot             - Reboot CPU
led                - Led demo
donut              - Spinning Donut demo
helloc             - Hello C
litex-demo-app> helloc
Hello C demo...
C: Hello, world!
```

## Сборка примера

Каталог примера содержит файл `add_dirs.d` этот файл содержит дополнительные каталоги которые надо включить в проект ПЛИС

```
litex/rtl
litex/build/litex_soc_m1/gateware
```

Файл `basics-graphics-music/scripts/steps/00_setup_intel_fpga.source_bash` анализирует наличие файла `add_dirs.d` в каталоге проекта и если он существует то добавляет каталоги в проект Quartus. 

Сборка примера и загрузка производится стандартными командми:
* 03_synthesize_for_fpga.bash - сборка
* 04_configure_fpga.bash - загрузка на плату

