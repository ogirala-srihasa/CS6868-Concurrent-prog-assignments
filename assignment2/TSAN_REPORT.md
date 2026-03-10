
1. The first data race(TSAN) detected is between a write and read to the same location caused by Snapshot.update(called by updater_worker) and Snapshot.scan(called by reader_worker) in test_concurrent_scans of test_manual.ml
```
==================                
WARNING: ThreadSanitizer: data race (pid=15202)
  Read of size 8 at 0x7fffe41ffe40 by thread T14 (mutexes: write M0):
    #0 camlSnapshot.fun_364 /workspace_root/Snapshot.ml:23 (test_manual.exe+0x4f4f0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlStdlib__Array.init_295 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/array.ml:54 (test_manual.exe+0x6bca4) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlSnapshot.scan_345 /workspace_root/Snapshot.ml:27 (test_manual.exe+0x4f54d) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlDune__exe__Test_manual.reader_worker_522 /workspace_root/test_manual.ml:111 (test_manual.exe+0x4e319) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Previous write of size 8 at 0x7fffe41ffe40 by thread T12 (mutexes: write M1):
    #0 caml_modify runtime/memory.c:225 (test_manual.exe+0xd1561) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlSnapshot.update_335 /workspace_root/Snapshot.ml:18 (test_manual.exe+0x4f3f5) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlDune__exe__Test_manual.updater_worker_494 /workspace_root/test_manual.ml:103 (test_manual.exe+0x4e209) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M0 (0x72b4000002c0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M1 (0x72b4000001b0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T14 (tid=15231, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlDune__exe__Test_manual.test_concurrent_scans_529 /workspace_root/test_manual.ml:120 (test_manual.exe+0x4e5ed) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:199 (test_manual.exe+0x4f1f8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #10 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #12 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #13 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T12 (tid=15229, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlDune__exe__Test_manual.test_concurrent_scans_529 /workspace_root/test_manual.ml:119 (test_manual.exe+0x4e59f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:199 (test_manual.exe+0x4f1f8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #10 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #12 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #13 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

SUMMARY: ThreadSanitizer: data race /workspace_root/Snapshot.ml:23 in camlSnapshot.fun_364
==================
```
2. This race is caused by read and write to the same location caused by caused by Snapshot.update(called by updater_worker) and Snapshot.scan(called by reader_worker) in test_concurrent_scans of test_manual.ml
```
==================
WARNING: ThreadSanitizer: data race (pid=15202)
  Read of size 8 at 0x7fffe41ffe10 by thread T14 (mutexes: write M0):
    #0 camlSnapshot.fun_364 /workspace_root/Snapshot.ml:23 (test_manual.exe+0x4f4f0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlStdlib__Array.init_295 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/array.ml:56 (test_manual.exe+0x6bd02) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlSnapshot.scan_345 /workspace_root/Snapshot.ml:27 (test_manual.exe+0x4f54d) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlDune__exe__Test_manual.reader_worker_522 /workspace_root/test_manual.ml:111 (test_manual.exe+0x4e319) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Previous write of size 8 at 0x7fffe41ffe10 by thread T12 (mutexes: write M1):
    #0 caml_modify runtime/memory.c:225 (test_manual.exe+0xd1561) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlSnapshot.update_335 /workspace_root/Snapshot.ml:18 (test_manual.exe+0x4f3f5) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlDune__exe__Test_manual.updater_worker_494 /workspace_root/test_manual.ml:104 (test_manual.exe+0x4e230) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M0 (0x72b4000002c0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M1 (0x72b4000001b0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T14 (tid=15231, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlDune__exe__Test_manual.test_concurrent_scans_529 /workspace_root/test_manual.ml:120 (test_manual.exe+0x4e5ed) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:199 (test_manual.exe+0x4f1f8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #10 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #12 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #13 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T12 (tid=15229, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlDune__exe__Test_manual.test_concurrent_scans_529 /workspace_root/test_manual.ml:119 (test_manual.exe+0x4e59f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:199 (test_manual.exe+0x4f1f8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #10 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #12 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #13 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

SUMMARY: ThreadSanitizer: data race /workspace_root/Snapshot.ml:23 in camlSnapshot.fun_364
==================
```
3. This data race is also caused by read and write to the same location caused by Snapshot.update(called by updater_worker) and Snapshot.scan(called by reader_worker) in test_concurrent_scans of test_manual.ml
```
==================
WARNING: ThreadSanitizer: data race (pid=15202)
  Read of size 8 at 0x7fffe41ffe00 by thread T14 (mutexes: write M0):
    #0 camlSnapshot.fun_364 /workspace_root/Snapshot.ml:23 (test_manual.exe+0x4f4f0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlStdlib__Array.init_295 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/array.ml:56 (test_manual.exe+0x6bd02) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlSnapshot.scan_345 /workspace_root/Snapshot.ml:27 (test_manual.exe+0x4f54d) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlDune__exe__Test_manual.reader_worker_522 /workspace_root/test_manual.ml:111 (test_manual.exe+0x4e319) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Previous write of size 8 at 0x7fffe41ffe00 by thread T12 (mutexes: write M1):
    #0 caml_modify runtime/memory.c:225 (test_manual.exe+0xd1561) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlSnapshot.update_335 /workspace_root/Snapshot.ml:18 (test_manual.exe+0x4f3f5) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlDune__exe__Test_manual.updater_worker_494 /workspace_root/test_manual.ml:105 (test_manual.exe+0x4e257) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M0 (0x72b4000002c0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M1 (0x72b4000001b0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T14 (tid=15231, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlDune__exe__Test_manual.test_concurrent_scans_529 /workspace_root/test_manual.ml:120 (test_manual.exe+0x4e5ed) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:199 (test_manual.exe+0x4f1f8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #10 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #12 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #13 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T12 (tid=15229, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlDune__exe__Test_manual.test_concurrent_scans_529 /workspace_root/test_manual.ml:119 (test_manual.exe+0x4e59f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:199 (test_manual.exe+0x4f1f8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #10 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #12 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #13 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

SUMMARY: ThreadSanitizer: data race /workspace_root/Snapshot.ml:23 in camlSnapshot.fun_364
==================
```
4.This is a data race caused by write and read to the same location caused by Snapshot.update(called by worker_2(even thread)) and Snapshot.scan(called by worker_2(odd thread)) in high_contention test of test_manual.ml 
```
==================
WARNING: ThreadSanitizer: data race (pid=15202)
  Write of size 8 at 0x7ffff5825f68 by thread T26 (mutexes: write M0):
    #0 caml_modify runtime/memory.c:225 (test_manual.exe+0xd1561) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlSnapshot.update_335 /workspace_root/Snapshot.ml:18 (test_manual.exe+0x4f3f5) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlDune__exe__Test_manual.worker_2_555 /workspace_root/test_manual.ml:165 (test_manual.exe+0x4ec9e) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Previous read of size 8 at 0x7ffff5825f68 by thread T24 (mutexes: write M1):
    #0 camlSnapshot.fun_364 /workspace_root/Snapshot.ml:23 (test_manual.exe+0x4f4f0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlStdlib__Array.init_295 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/array.ml:54 (test_manual.exe+0x6bca4) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlSnapshot.scan_345 /workspace_root/Snapshot.ml:27 (test_manual.exe+0x4f54d) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlDune__exe__Test_manual.worker_2_555 /workspace_root/test_manual.ml:172 (test_manual.exe+0x4ed51) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M0 (0x72b4000001b0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M1 (0x72b4000004e0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T26 (tid=15243, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__List.init_dps_1346 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/list.ml:68 (test_manual.exe+0x62fd8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlStdlib__List.init_326 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/list.ml:70 (test_manual.exe+0x6323f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 camlDune__exe__Test_manual.test_high_contention_565 /workspace_root/test_manual.ml:185 (test_manual.exe+0x4eeb6) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:200 (test_manual.exe+0x4f202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #10 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #12 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #13 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #14 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #15 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T24 (tid=15241, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__List.init_326 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/list.ml:69 (test_manual.exe+0x631f7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.test_high_contention_565 /workspace_root/test_manual.ml:185 (test_manual.exe+0x4eeb6) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:200 (test_manual.exe+0x4f202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #10 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #11 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #12 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #13 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #14 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

SUMMARY: ThreadSanitizer: data race runtime/memory.c:225 in caml_modify
==================
```
5.This is a data race caused by write and read to the same location caused by Snapshot.update(called by worker_2(even thread)) and Snapshot.scan(called by worker_2(odd thread)) in high_contention test of test_manual.ml 
```
==================
WARNING: ThreadSanitizer: data race (pid=15202)
  Write of size 8 at 0x7ffff5825f58 by thread T26 (mutexes: write M0):
    #0 caml_modify runtime/memory.c:225 (test_manual.exe+0xd1561) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlSnapshot.update_335 /workspace_root/Snapshot.ml:18 (test_manual.exe+0x4f3f5) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlDune__exe__Test_manual.worker_2_555 /workspace_root/test_manual.ml:165 (test_manual.exe+0x4ec9e) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Previous read of size 8 at 0x7ffff5825f58 by thread T24 (mutexes: write M1):
    #0 camlSnapshot.fun_364 /workspace_root/Snapshot.ml:23 (test_manual.exe+0x4f4f0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #1 camlStdlib__Array.init_295 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/array.ml:56 (test_manual.exe+0x6bd02) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 camlSnapshot.scan_345 /workspace_root/Snapshot.ml:27 (test_manual.exe+0x4f54d) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlDune__exe__Test_manual.worker_2_555 /workspace_root/test_manual.ml:172 (test_manual.exe+0x4ed51) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__Domain.body_757 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:266 (test_manual.exe+0x8717f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 caml_callback_exn runtime/callback.c:206 (test_manual.exe+0xab013) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_callback_res runtime/callback.c:321 (test_manual.exe+0xabc94) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 domain_thread_func runtime/domain.c:1273 (test_manual.exe+0xb1940) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M0 (0x72b4000001b0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Mutex M1 (0x72b4000004e0) created at:
    #0 pthread_mutex_init ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1315 (libtsan.so.2+0x594cd) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_plat_mutex_init runtime/platform.c:59 (test_manual.exe+0xdbf32) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_init_domains runtime/domain.c:996 (test_manual.exe+0xaf8ea) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 caml_init_gc runtime/gc_ctrl.c:359 (test_manual.exe+0xbd202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 caml_startup_common runtime/startup_nat.c:106 (test_manual.exe+0xef1a7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef1a7)
    #6 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #8 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #9 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T26 (tid=15243, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__List.init_dps_1346 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/list.ml:68 (test_manual.exe+0x62fd8) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlStdlib__List.init_326 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/list.ml:70 (test_manual.exe+0x6323f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 camlDune__exe__Test_manual.test_high_contention_565 /workspace_root/test_manual.ml:185 (test_manual.exe+0x4eeb6) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:200 (test_manual.exe+0x4f202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #10 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #11 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #12 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #13 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #14 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #15 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

  Thread T24 (tid=15241, running) created by main thread at:
    #0 pthread_create ../../../../src/libsanitizer/tsan/tsan_interceptors_posix.cpp:1022 (libtsan.so.2+0x5ac1a) (BuildId: 2a13a7710e361d06f7babbea53065ca2be93f738)
    #1 caml_domain_spawn runtime/domain.c:1347 (test_manual.exe+0xb0a60) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #2 caml_c_call <null> (test_manual.exe+0xef9fb) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #3 camlStdlib__Domain.spawn_752 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/domain.ml:284 (test_manual.exe+0x87096) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #4 camlStdlib__List.init_326 /home/vishnu/.opam/5.4.0+tsan/.opam-switch/build/ocaml-compiler.5.4.0/stdlib/list.ml:69 (test_manual.exe+0x631f7) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #5 camlDune__exe__Test_manual.test_high_contention_565 /workspace_root/test_manual.ml:185 (test_manual.exe+0x4eeb6) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #6 camlDune__exe__Test_manual.entry /workspace_root/test_manual.ml:200 (test_manual.exe+0x4f202) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #7 caml_program <null> (test_manual.exe+0x4b0c9) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #8 caml_start_program <null> (test_manual.exe+0xefb1f) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #9 caml_startup_common runtime/startup_nat.c:127 (test_manual.exe+0xef2c0) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #10 caml_startup_common runtime/startup_nat.c:86 (test_manual.exe+0xef2c0)
    #11 caml_startup_exn runtime/startup_nat.c:134 (test_manual.exe+0xef36b) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)
    #12 caml_startup runtime/startup_nat.c:139 (test_manual.exe+0xef36b)
    #13 caml_main runtime/startup_nat.c:146 (test_manual.exe+0xef36b)
    #14 main runtime/main.c:37 (test_manual.exe+0x4ac09) (BuildId: 136bb6a4946d1eada7c85881e90a25af9cffc1e1)

SUMMARY: ThreadSanitizer: data race runtime/memory.c:225 in caml_modify
==================
✓ Passed: Sequential test passed 
✓ Passed: Concurrent updates test passed 
✓ Passed: Concurrent scans test passed 
✓ Passed: High contention test passed 
All manual tests passed!
ThreadSanitizer: reported 5 warnings
```

* Atomic implementation avoids data races because these locations enforce a strict  happens before relationship between 2 conflicting operations

when implemented using atomics(no data races) the terminal output will be 

```
✓ Passed: Sequential test passed 
✓ Passed: Concurrent updates test passed 
✓ Passed: Concurrent scans test passed 
✓ Passed: High contention test passed 
All manual tests passed!
```


* The output for the part-5 of Assignment is generated using Vishnu Teja Surla's(CS25M050) system since it is not possible to generate backtrace of TSAN warnings on mac