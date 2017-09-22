#!/bin/tcsh -f
# Remove non primary data files
pushd tests
rm -rf *~ *sim *trace *vcd *dump `ls -1 | egrep -v '(\.v$|\.csh|\.ucf|\.py|\.s$|spartan|xc95|opc6system|opc6copro|Make*|stdin)'`

if ( $#argv > 0 ) then
    if ( $argv[1] == "clean" ) exit
endif

#Check for pypy3
pypy3 --version > /dev/null
if ( $status) then
    set pyexec = python3
else
    set pyexec = pypy3
endif

set assembler = ../opc6asm.py
#set assembler = ../opc6byteasm.py

set testlist = ( fib robfib  hello string  davefib mul32 udiv32 sqrt davefib_int pi-spigot-rev testpsr sqrt_int pi-spigot-bruce sieve e-spigot-rev pi-spigot-rev32 bigsieve pushpop nqueens )

foreach test ( $testlist )
    echo "Running Test $test"
    # Assemble the test
    python3 ${assembler} ${test}.s ${test}.hex >  ${test}.lst
    
    ${pyexec} ../opc6emu.py ${test}.hex ${test}.dump  | tee  ${test}.trace | python3 ../../utils/show_stdout.py
    # Test bench expects the hex file to be called 'test.hex'
    cp ${test}.hex test.hex
    # Run icarus verilog to compile the testbench only if there is no stdin file
    foreach option ( NEGEDGE_MEMORY POSEDGE_MEMORY )
        iverilog -D_simulation=1 -D${option}=1 ../opc6tb.v ../opc6cpu.v
        # -D_dumpvcd=1
        
        # Execute the test bench
        ./a.out | tee ${test}_${option}.sim
        # Save the results
        if ( -e dump.vcd) then
            mv dump.vcd ${test}_${option}.vcd
        endif            
        mv test.vdump ${test}_${option}.vdump
    end
end

echo ""
echo "Comparing memory dumps between emulation and simulation"
echo "-------------------------------------------------------"
foreach test ( $testlist )
    if ( ! -e $test.stdin ) then
        foreach option ( NEGEDGE_MEMORY POSEDGE_MEMORY )
            printf "%32s :" ${test}_${option}
            if "${test}" =~ "*int" then
                python3 ../../utils/mdumpcheck.py ${test}.dump  ${test}_${option}.vdump 0xF000 0x0500 0xFFFF
            else
                python3 ../../utils/mdumpcheck.py ${test}.dump  ${test}_${option}.vdump
            endif
        end
    endif        
end
popd
