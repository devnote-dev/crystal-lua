echo off
git clone https://github.com/walterschell/Lua --branch v5.4.4 ext
cd ext && mkdir build && cd build
cmake .. -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
cmake --build . --config Release
