FRAMEWORKS='-framework AppKit -framework CoreVideo -framework Metal -framework MetalKit'
TIMEFORMAT=%R
FLAGS='-std=c++20 --debug'
IGNORE='-Wno-nullability-completeness'

platform()
{
    clang ${FRAMEWORKS} CNC_Main.mm -o clock ${FLAGS} ${IGNORE}
}

main()
{
    time platform
}

main