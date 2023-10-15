cxx_binary(
    name = "hello",
    srcs = ["main.cc"],
    deps = [":lib"],
)

cxx_library(
    name = "lib",
    srcs = ["lib.cc"],
    exported_headers = ["lib.h"],
)
