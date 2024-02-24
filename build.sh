FRAMEWORKS='-framework AppKit -framework CoreVideo -framework Metal -framework MetalKit'
TIMEFORMAT=%R
FLAGS='-lstdc++ -std=c++20 -O2 -pedantic'
IGNORE='-Wno-nullability-completeness'

platform()
{
    clang ${FRAMEWORKS} CNC_Main.mm -o clock ${FLAGS} ${IGNORE}
}

main()
{
    time platform
    CODE_SIZE=$(cloc --exclude-dir=libs . | grep -o -E '([0-9]+)' | tail -1)
    echo "-> LINES OF CODE: " $CODE_SIZE
}

main