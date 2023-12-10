.PHONY: build-run, mem-profile, performance 

build-run:
	nim c --run main.nim

mem-profile:
	nim c --profiler:off --stacktrace:on -d:memProfiler  --run main.nim > output.txt

performance:
	nim c --profiler:on --stacktrace:on --run main.nim > output.txt

