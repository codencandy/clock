FRAMEWORKS='-framework AppKit -framework CoreVideo'
TIMEFORMAT=%R

platform()
{
    clang ${FRAMEWORKS} CNC_Main.mm -o clock --debug
}

main()
{
    time platform
}

main