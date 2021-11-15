namespace Ahoris {
    public class StopWatch : Gtk.Box {
        public signal void started();
        
        private Gtk.Label label;
        private bool is_running = false;
        private bool is_paused = false;
        private int time = 0;
        
        construct {
            var df = new Pango.FontDescription();
            df.set_family("Sans");
            df.set_size(14 * Pango.SCALE);
            df.set_weight(BOLD);
            df.set_style(ITALIC);
            var attr1 = new Pango.AttrFontDesc(df);
            var attrlist = new Pango.AttrList();
            attrlist.insert((owned) attr1);
            
            label = new Gtk.Label("0:00.00") {
                attributes = attrlist, use_markup = true
            };
            
            orientation = HORIZONTAL;
            pack_start(label, false, false);
        }
        
        public async void run() {
            is_running = true;
            is_paused = false;
            time = 0;
            started();
            int hour_span = 60 * 60 * 100;
            while (is_running) {
                if (!is_paused) {
                    time += 1;
                    if (time < hour_span) {
                        label.label = "%02d:%02d.%02d".printf(
                            time / 100 / 60,
                            time / 100 % 60,
                            time % 60
                        );
                    } else {
                        label.label = "%d:%02d:%02d.%02d".printf(
                            time / 100 / 60 / 60,
                            time / 100 / 60 % 60,
                            time / 100 % 60,
                            time % 60
                        );
                    }
                }
                Timeout.add(10, run.callback);
                yield;
            }
        }
        
        public void stop() {
            is_running = false;
        }
        
        public void pause() {
            is_paused = true;
        }
        
        public void unpause() {
            is_paused = false;
        }
    }
}