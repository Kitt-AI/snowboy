{
    'targets': [{
        'target_name': 'snowboy',
        'sources': [
            'swig/Node/snowboy.cc'
        ],
        'conditions': [
            ['OS=="mac"', {
                'link_settings': {
                    'libraries': [
                        '<(module_root_dir)/lib/osx/libsnowboy-detect.a',
                    ]
                }
            }],
            ['OS=="linux" and target_arch=="x64"', {
                'link_settings': {
                    'libraries': [
                        '<(module_root_dir)/lib/ubuntu64/libsnowboy-detect.a',
                    ]
                }
            }],
            ['OS=="linux" and target_arch=="arm"', {
                'link_settings': {
                    'libraries': [
                        '<(module_root_dir)/lib/rpi/libsnowboy-detect.a',
                    ]
                }
            }]
        ],
        'cflags': [
            '-std=c++11',
            '-fexceptions',
            '-Wall',
            '-D_GLIBCXX_USE_CXX11_ABI=0'
        ],
        'cflags!': [
            '-fno-exceptions'
        ],
        'cflags_cc!': [
            '-fno-exceptions'
        ],
        'include_dirs': [
            "<!(node -e \"require('nan')\")",
            "<!(pwd)/include"
        ],
        'libraries': [
            '-lcblas'
        ],
        'xcode_settings': {
            'MACOSX_DEPLOYMENT_TARGET': '10.11',
            "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
            'OTHER_CFLAGS': [
                '-std=c++11',
                '-stdlib=libc++'
            ]
        }
    },
    {
      "target_name": "action_after_build",
      "type": "none",
      "dependencies": [ "<(module_name)" ],
      "copies": [
        {
          "files": [ "<(PRODUCT_DIR)/<(module_name).node" ],
          "destination": "<(module_path)"
        }
      ]
    }]
}
