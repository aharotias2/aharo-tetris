project('com.github.aharotias2.AharoTetris', 'vala', 'c', version: '0.0.1')

libm_dep = meson.get_compiler('c').find_library('libm')

gnome = import('gnome')
resources = gnome.compile_resources(
  'Ahoris.resources',
  'data/gresources.xml',
  source_dir: 'data'
)

executable(
  meson.project_name(),
  [
    'src/aharo-tetris.vala',
    'src/labelbuilder.vala',
    'src/stopwatch.vala',
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
  'data/icon-128.png', rename: meson.project_name() + '.png',
  install_dir: get_option('datadir') / 'icons/hicolor/128x128/apps'
)

install_data(
  'data/' + meson.project_name() + '.desktop',
  install_dir: get_option('datadir') / 'applications'
)
