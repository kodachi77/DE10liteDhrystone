update_section_mapping .bss onchip_ram
update_section_mapping .rodata onchip_ram
update_section_mapping .rwdata onchip_ram
update_section_mapping .stack onchip_ram
update_section_mapping .text onchip_ram

update_section_mapping .heap sdram
 
set_setting hal.timestamp_timer timer_0

set_setting hal.linker.exception_stack_memory_region_name onchip_ram
set_setting hal.linker.interrupt_stack_memory_region_name onchip_ram

set_setting hal.make.bsp_cflags_debug -g0
set_setting hal.make.bsp_cflags_optimization -O3

set_setting hal.enable_small_c_library 1
set_setting hal.enable_c_plus_plus 0
set_setting hal.enable_reduced_device_drivers 1