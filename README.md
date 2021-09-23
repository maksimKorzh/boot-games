# boot-games
A collection of my boot sector games

# SokobanOS & the boot sector game development kungfu
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/6h5QM_bwBhs/0.jpg)](https://www.youtube.com/watch?v=6h5QM_bwBhs)

# Run in emulator
1. Pick up sokobanos.img file the game source folder
2. Command to run in QEMU: <strong>qemu-system-i386 -hda sokobanos.img</strong>
3. Run in online emulator(https://copy.sh/v86/): click upload HDD image then start emulation

# Create bootable USB (on linux) & run on real hardware 
1. Plug in USB flash drive
2. Run command <strong>sudo fdisk -l</strong> => /dev/sdb should be your USB flash drive
3. Navigate to where game image is located
4. Run command <strong>dd if=sokobanos.img of=/dev/sdb count=2880 bs=512</strong>
5. Boot from USB flash drive

# Useful resources
CHS addresses: https://en.wikipedia.org/wiki/Cylinder-head-sector</br>
x86 Real mode: https://wiki.osdev.org/Real_Mode<br>
x86 Real mode memory segmentation: https://wiki.osdev.org/Segmentation<br>
x86 Memory map: https://wiki.osdev.org/Memory_Map_(x86)<br>
x86 BIOS interrupts: http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm<br>
x86 Assembly registers: https://www.assemblylanguagetuts.com/x86-assembly-registers-explained/</br>
x86 Assembly instructions: https://www.aldeid.com/wiki/X86-assembly/Instructions</br>
x86 Assembler Instruction Set Opcode Table http://sparksandflames.com/files/x86InstructionChart.html
x86 Online emulator: https://copy.sh/v86/</br>
