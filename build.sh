FRAMEWORKS='-framework AppKit'
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