project('com.github.aharotias2.Ahoris', 'vala', 'c', version: '0.0.1')

libm_dep = meson.get_compiler('c').find_library('libm')

gnome = import('gnome')
resources = gnome.compile_resources(
  'Ahoris.resources',
  'data/gresources.xml',
  source_dir: 'data'
)

executable(
  'com.github.aharotias2.Ahoris',
  [
    'src/ahoris.vala',
    resources
  ],
  dependencies: [
    dependency('gdk-3.0'),
    dependency('gtk+-3.0'),
    libm_dep
  ],
  install: true,
  install_dir: get_option('prefix') / 'bin'
)

