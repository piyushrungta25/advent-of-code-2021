include imports

proc pecho[T](args: varargs[T]) =
    for arg in args:
        echo pretty(%* arg)
        echo "------"