load("@prelude//:paths.bzl", "paths")
load("@prelude//utils:graph_utils.bzl", "post_order_traversal")


_Module = record(
    source = field(Artifact),
    interface = field(Artifact),
    object = field(Artifact),
)


def _modules_by_name(ctx: AnalysisContext, *, sources: list[Artifact]) -> dict[str, _Module]:
    modules = {}

    for src in sources:
        module_name = paths.split_extension(src.basename)[0]
        interface_path = paths.replace_extension(src.short_path, ".hi")
        interface = ctx.actions.declare_output(interface_path)
        object_path = paths.replace_extension(src.short_path, ".o")
        object = ctx.actions.declare_output(object_path)
        modules[module_name] = _Module(source = src, interface = interface, object = object)

    return modules


def _ghc_depends(ctx: AnalysisContext, *, filename: str, sources: list[Artifact]) -> Artifact:
    dep_file = ctx.actions.declare_output(filename)
    dep_args = cmd_args("ghc", "-M", "-dep-suffix", "", "-dep-makefile", dep_file.as_output())
    dep_args.add(sources)
    ctx.actions.run(dep_args, category = "ghc_depends")

    return dep_file


def _parse_depends(depends: str) -> dict[str, list[str]]:
    graph = {}

    for line in depends.splitlines():
        if line.startswith("#"):
            continue

        k, v = line.strip().split(" : ", 1)
        vs = v.split(" ")

        module_name = paths.split_extension(paths.basename(k))[0]
        deps = [
            paths.split_extension(paths.basename(v))[0]
            for v in vs
            if paths.split_extension(v)[1] != ".hs"
        ]

        graph.setdefault(module_name, []).extend(deps)

    return graph


def _compile_module(
        ctx: AnalysisContext,
        *,
        module_name: str,
        modules: dict[str, _Module],
        graph: dict[str, list[str]],
        outputs: dict[Artifact, Artifact],
        ) -> None:
    module = modules[module_name]

    compile_args = cmd_args("ghc", "-c", module.source)
    compile_args.add("-hidir", cmd_args(outputs[module.interface].as_output()).parent())
    compile_args.add("-odir", cmd_args(outputs[module.object].as_output()).parent())

    for dep_name in graph[module_name]:
        dep = modules[dep_name]
        compile_args.add(cmd_args(outputs[dep.interface], format = "-i%s").parent())

    ctx.actions.run(compile_args, category = "ghc_compile", identifier = module_name)


def _link_binary(ctx, *, filename: str, objects: list[Artifact]):
    output = ctx.actions.declare_output(filename)
    link_args = cmd_args("ghc", "-o", output.as_output())
    link_args.add(objects)
    ctx.actions.run(link_args, category = "ghc_link")

    return output


def _haskell_binary_impl(ctx: AnalysisContext) -> list[Provider]:
    dep_name = ctx.attrs.name + ".depends"
    dep_file = _ghc_depends(ctx, filename = dep_name, sources = ctx.attrs.srcs)
    modules = _modules_by_name(ctx, sources = ctx.attrs.srcs)

    def compile(ctx, artifacts, outputs, dep_file=dep_file, modules=modules):
        graph = _parse_depends(artifacts[dep_file].read_string())

        for module_name in post_order_traversal(graph):
            _compile_module(
                ctx,
                module_name = module_name,
                modules = modules,
                graph = graph,
                outputs = outputs,
            )

    interfaces = [module.interface for module in modules.values()]
    objects = [module.object for module in modules.values()]
    ctx.actions.dynamic_output(
        dynamic = [dep_file],
        inputs = ctx.attrs.srcs,
        outputs = interfaces + objects,
        f = compile)

    output = _link_binary(ctx, filename = ctx.attrs.name, objects = objects)

    return [DefaultInfo(default_output = output), RunInfo(args = cmd_args([output]))]


haskell_binary = rule(
    impl = _haskell_binary_impl,
    attrs = {
        "srcs": attrs.list(attrs.source()),
    },
)
