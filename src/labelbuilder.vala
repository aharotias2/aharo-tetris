/*
 * This file is part of Bakamon-Go.
 *
 *     Bakamon-Go is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Bakamon-Go is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with Bakamon-Go.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2021 Takayuki Tanaka
 */

namespace Ahoris {
    public class LabelBuilder : Object {
        private Pango.FontDescription fd;
        private string label_value;
        private string? color_name = null;
        
        private LabelBuilder() {
            fd = new Pango.FontDescription();
        }

        public static LabelBuilder create() {
            return new LabelBuilder();
        }
        
        public LabelBuilder family(string font_family_name) {
            fd.set_family(font_family_name);
            return this;
        }
        
        public LabelBuilder size(int size_value) {
            fd.set_size(size_value * Pango.SCALE);
            return this;
        }
        
        public LabelBuilder weight(Pango.Weight weight_value) {
            fd.set_weight(weight_value);
            return this;
        }
        
        public LabelBuilder style(Pango.Style style_value) {
            fd.set_style(style_value);
            return this;
        }
        
        public LabelBuilder gravity(Pango.Gravity gravity_value) {
            fd.set_gravity(gravity_value);
            return this;
        }
        
        public LabelBuilder label(string label_value) {
            this.label_value = label_value;
            return this;
        }

        public LabelBuilder color(string color_name) {
            this.color_name = color_name;
            return this;
        }
                
        public Gtk.Label build() {
            var attr = new Pango.AttrFontDesc(fd);
            var attr_list = new Pango.AttrList();
            attr_list.insert((owned) attr);
            var label_widget = new Gtk.Label(
                    color_name != null ? @"<span color=\"$(color_name)\">$(label_value)</span>" : label_value) {
                attributes = attr_list,
                use_markup = true
            };
            return label_widget;
        }
        
        public Pango.AttrList attrlist() {
            var attr = new Pango.AttrFontDesc(fd);
            var attr_list = new Pango.AttrList();
            attr_list.insert((owned) attr);
            return attr_list;
        }
    }
}
