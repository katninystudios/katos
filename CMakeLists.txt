cmake_minimum_required(VERSION 4.0)
project(KatOS)

# find nasm
find_program(NASM nasm)
if(NOT NASM)
   message(FATAL_ERROR "NASM not found!")
endif()

# build bootloader
add_custom_command(
   OUTPUT ${CMAKE_BINARY_DIR}/boot.bin
   COMMAND ${NASM} -f bin -o ${CMAKE_BINARY_DIR}/boot.bin ${CMAKE_SOURCE_DIR}/boot.asm 
   DEPENDS ${CMAKE_SOURCE_DIR}/boot.asm 
   COMMENT "Building bootloader"
)

# add custom target
add_custom_target(bootloader ALL DEPENDS ${CMAKE_BINARY_DIR}/boot.bin)

# qemu run target 
add_custom_target(run 
   COMMAND qemu-system-i386 -fda ${CMAKE_BINARY_DIR}/boot.bin 
   DEPENDS bootloader 
   COMMENT "Running in QEMU"
)