TIMEFORMAT=%R

platform()
{
    clang CNC_Main.mm -o clock --debug
}

main()
{
    time platform
}

main