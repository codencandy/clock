FRAMEWORKS='-framework AppKit -framework CoreVideo -framework Metal -framework MetalKit'
TIMEFORMAT=%R
FLAGS='-std=c++20 --debug'

platform()
{
    clang ${FRAMEWORKS} CNC_Main.mm -o clock ${FLAGS}
}

main()
{
    time platform
}

main