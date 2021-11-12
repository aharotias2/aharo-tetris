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

install_data(
  'data/icon-128.png', rename: 'com.github.aharotias2.ahoris.png',
  install_dir: get_option('datadir') / 'share/icons/hicolor/128x128/apps'
)

install_data(
  'data/com.github.aharotias2.ahoris.desktop',
  install_dir: get_option('datadir') / 'share/applications'
)
