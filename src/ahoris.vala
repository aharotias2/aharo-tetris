/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 * Copyright 2021 Takayuki Tanaka
 */

namespace Ahoris {
    public errordomain GameError {
        LOGICAL_ERROR
    }
    
    public enum ModelSize {
        MODEL_10X20,
        MODEL_15X30;
        
        public int x_length() {
            switch (this) {
              default:
              case MODEL_10X20:
                return 10;
              case MODEL_15X30:
                return 15;
            }
        }
        
        public int y_length() {
            switch (this) {
              default:
              case MODEL_10X20:
                return 20;
              case MODEL_15X30:
                return 30;
            }
        }
    }
    
    public enum FieldStatus {
        EMPTY, BLOCKED;
    }

    public enum OverlappingState {
        NOT_OVERLAPPED, OVER_LEFT, OVERLAPPED, OVER_RIGHT
    }
    
    public struct FieldBlock {
        public FieldStatus status;
        public Gdk.RGBA base_color;
    }

    public class FallingBlock {
        public const uint8[,] PATTERN_A = {
            {0, 0, 0, 0},
            {1, 1, 1, 1},
            {0, 0, 0, 0},
            {0, 0, 0, 0}
        };
        
        public const Gdk.RGBA PATTERN_A_COLOR = { 0.5, 0.75, 0.75, 1.0 };
        
        public const uint8[,] PATTERN_B = {
            {0, 0, 0, 0},
            {1, 1, 0, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        };
        
        public const Gdk.RGBA PATTERN_B_COLOR = { 0.75, 0.25, 0.25, 1.0 };
        
        public const uint8[,] PATTERN_C = {
            {0, 0, 0, 0},
            {0, 0, 1, 1},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        };
        
        public const Gdk.RGBA PATTERN_C_COLOR = { 0.25, 0.75, 0.25, 1.0 };
        
        public const uint8[,] PATTERN_D = {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0}
        };
        
        public const Gdk.RGBA PATTERN_D_COLOR = { 0.25, 0.25, 1.0, 1.0 };
        
        public const uint8[,] PATTERN_E = {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {0, 0, 1, 0},
            {0, 0, 1, 0}
        };
        
        public const Gdk.RGBA PATTERN_E_COLOR = { 0.75, 0.50, 0.25, 1.0 };
        
        public const uint8[,] PATTERN_F = {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        };
        
        public const Gdk.RGBA PATTERN_F_COLOR = { 0.75, 0.75, 0.25, 1.0 };
        
        public const uint8[,] PATTERN_G = {
            {0, 0, 0, 0},
            {1, 1, 1, 0},
            {0, 1, 0, 0},
            {0, 0, 0, 0}
        };
        
        public const Gdk.RGBA PATTERN_G_COLOR = { 0.75, 0.25, 0.75, 1.0 };
        
        public uint8[,] data;
        public Gdk.RGBA base_color;
        public Gdk.Point position;
        public bool is_falling;
        
        public FallingBlock(int pattern_num) {
            init(pattern_num);
        }
        
        public FallingBlock.random_pattern() {
            init(Random.int_range(0, 7));
        }
        
        private void init(int pattern_num) {
            uint8[,] ptr;
            switch (pattern_num % 7) {
              default:
              case 0:
                ptr = PATTERN_A;
                base_color = PATTERN_A_COLOR;
                break;
              case 1:
                ptr = PATTERN_B;
                base_color = PATTERN_B_COLOR;
                break;
              case 2:
                ptr = PATTERN_C;
                base_color = PATTERN_C_COLOR;
                break;
              case 3:
                ptr = PATTERN_D;
                base_color = PATTERN_D_COLOR;
                break;
              case 4:
                ptr = PATTERN_E;
                base_color = PATTERN_E_COLOR;
                break;
              case 5:
                ptr = PATTERN_F;
                base_color = PATTERN_F_COLOR;
                break;
              case 6:
                ptr = PATTERN_G;
                base_color = PATTERN_G_COLOR;
                break;
            }
            data = new uint8[4, 4];
            for (int y = 0; y < 4; y++) {
                for (int x = 0; x < 4; x++) {
                    data[y, x] = ptr[y, x];
                }
            }
            int random_value = Random.int_range(0, 4);
            for (int i = 0; i < random_value; i++) {
                rotate_right();
            }
            
            is_falling = true;
        }
        
        public void rotate_right() {
            uint8[,] tmp = new uint8[4, 4];
            for (int y = 0; y < 4; y++) {
                for (int x = 0; x < 4; x++) {
                    tmp[x, 3 - y] = data[y, x];
                }
            }
            for (int y = 0; y < 4; y++) {
                for (int x = 0; x < 4; x++) {
                    data[y, x] = tmp[y, x];
                }
            }
        }
        
        public void rotate_left() {
            uint8[,] tmp = new uint8[4, 4];
            for (int y = 0; y < 4; y++) {
                for (int x = 0; x < 4; x++) {
                    tmp[3 - x, y] = data[y, x];
                }
            }
            for (int y = 0; y < 4; y++) {
                for (int x = 0; x < 4; x++) {
                    data[y, x] = tmp[y, x];
                }
            }
        }
    }
    
    public class GameModel : Object {
        public signal void reserve(FallingBlock falling_reserved);
        public signal void changed();
        public signal void score_changed(int score);
        public signal void game_over();
        public ModelSize size { get; private set; }
        public int speed { get; set; default = 90; }
        public FallingBlock falling { get; private set; }
        public FallingBlock falling_reserved { get; private set; }
        public int score { get; private set; default = 0; }
        public bool is_running {
            get {
                return !is_game_over;
            }
        }
        private bool is_game_over;
        private FieldBlock[,] field;
        private bool is_paused;
        
        public GameModel(ModelSize size) {
            reset_by_size(size);
        }
        
        public FieldStatus get_status(int y, int x) {
            return field[y, x].status;
        }
        
        public Gdk.RGBA get_block_color(int y, int x) {
            return field[y, x].base_color;
        }
        
        public Gdk.Point get_falling_position() {
            return falling.position;
        }
        
        public async void start() throws GameError {
            falling = new FallingBlock.random_pattern();
            falling.position = Gdk.Point() {
                x = size.x_length() / 2 - 2,
                y = -4
            };
            falling_reserved = new FallingBlock.random_pattern();
            falling_reserved.position = Gdk.Point() {
                x = size.x_length() / 2 - 2,
                y = -4
            };
            reserve(falling_reserved);
            is_game_over = false;
            is_paused = false;

            do {
                if (!is_paused) {
                    if (falling.is_falling) {
                        if (can_go_down()) {
                            falling.position.y++;
                            changed();
                        } else {
                            yield fix_falling();
                            speed += 5;
                        }
                    } else {
                        speed += 5;
                    }
                }
                Timeout.add(60000 / speed, start.callback);
                yield;
            } while (!is_game_over);
        }
        
        public void force_exit() {
            is_game_over = true;
        }
        
        public void reset_by_size(ModelSize size) {
            this.size = size;
            this.field = new FieldBlock[size.y_length(), size.x_length()];
        }
        
        public void turn_left() {
            falling.rotate_left();
            switch (is_overlapped()) {
              case OVERLAPPED:
                falling.rotate_right();
                break;
              case OVER_LEFT:
                if (can_go_right()) {
                    go_right();
                } else {
                    falling.rotate_right();
                }
                break;
              case OVER_RIGHT:
                if (can_go_left()) {
                    go_left();
                } else {
                    falling.rotate_right();
                }
                break;
              default:
                changed();
                break;
            }
        }
        
        public void turn_right() {
            falling.rotate_right();
            switch (is_overlapped()) {
              case OVERLAPPED:
                falling.rotate_left();
                break;
              case OVER_LEFT:
                if (can_go_right()) {
                    go_right();
                } else {
                    falling.rotate_left();
                }
                break;
              case OVER_RIGHT:
                if (can_go_left()) {
                    go_left();
                } else {
                    falling.rotate_left();
                }
                break;
              default:
                changed();
                break;
            }
        }
        
        public void go_down_fast() throws GameError {
            if (can_go_down()) {
                falling.position.y++;
                changed();
            } else {
                is_paused = true;
                fix_falling.begin((obj, res) => {
                    is_paused = false;
                });
            }
        }
        
        public void go_left() {
            if (can_go_left()) {
                falling.position.x--;
                changed();
            }
        }
        
        public void go_right() {
            if (can_go_right()) {
                falling.position.x++;
                changed();
            }
        }
                
        private bool can_go_down() {
            for (int j = 3; j >= 0; j--) {
                for (int i = 0; i < 4; i++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (y < 0) {
                        continue;
                    }
                    if (falling.data[j, i] != 0) {
                        if (y + 1 >= size.y_length()) {
                            return false;
                        }
                        if (field[y + 1, x].status != EMPTY) {
                            return false;
                        }
                    }
                }
            }
            return true;
        }
        
        private bool can_go_left() {
            for (int i = 0; i < 4; i++) {
                for (int j = 3; j >= 0; j--) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (falling.data[j, i] != 0) {
                        if (y >= 0 && field[y, x - 1].status != EMPTY) {
                            return false;
                        }
                        if (x == 0) {
                            return false;
                        }
                    }
                }
            }
            return true;
        }
        
        private bool can_go_right() {
            for (int i = 3; i >= 0; i--) {
                for (int j = 0; j < 4; j++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (falling.data[j, i] != 0) {
                        if (y >= 0 && field[y, x + 1].status != EMPTY) {
                            return false;
                        }
                        if (x == size.x_length() - 1) {
                            return false;
                        }
                    }
                }
            }
            return true;
        }
        
        private OverlappingState is_overlapped() {
            for (int j = 0; j < 4; j++) {
                for (int i = 0; i < 4; i++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (falling.data[j, i] != 0) {
                        if (x < 0) {
                            return OVER_LEFT;
                        } else if (x >= size.x_length()) {
                            return OVER_RIGHT;
                        } else if (field[y, x].status != EMPTY) {
                            return OVERLAPPED;
                        }
                    }
                }
            }
            return NOT_OVERLAPPED;
        }
        
        private async void fix_falling() throws GameError {
            for (int j = 0; j < 4; j++) {
                for (int i = 0; i < 4; i++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (y < 0) {
                        continue;
                    }
                    if (field[y, x].status != EMPTY && falling.data[j, i] != 0) {
                        throw new GameError.LOGICAL_ERROR("このフローにこないようにプログラミングすること。");
                    }
                    if (falling.data[j, i] != 0) {
                        field[y, x] = FieldBlock() {
                            status = BLOCKED,
                            base_color = falling.base_color
                        };
                    }
                }
            }
            
            falling.is_falling = false;
            falling = falling_reserved;
            falling_reserved = new FallingBlock.random_pattern();
            falling_reserved.position = { size.x_length() / 2 - 2, -4 };
            changed();
            Idle.add(fix_falling.callback);
            yield;
            
            bool is_erased = false;
            int bonus = 1;
            
            do {
                
                is_erased = false;
                int j = size.y_length() - 1;
                int v1 = j;
                int v2 = 0;
                bool flag = true;
                bool[] v3 = new bool[size.y_length()];
                for (; j >= 0; j--) {
                    if (can_erase_row(j)) {
                        if (flag) {
                            v1 = j;
                            flag = false;
                        }
                        v3[j] = true;
                        v2++;
                        bonus++;
                        is_erased = true;
                    }
                }
                
                if (v2 > 0) {
                    yield erase_row(v3, bonus);
                    changed();
                    Timeout.add(200, fix_falling.callback);
                    yield;
                    bool move_completed = false;
                    while (!move_completed) {
                        move_completed = yield move_down(v1, v2);
                        changed();
                        Timeout.add(50, fix_falling.callback);
                        yield;
                    }
                    changed();
                    Timeout.add(200, fix_falling.callback);
                    yield;
                    
                    bonus *= 2;
                }
                
            } while (is_erased);

            if (!can_continue()) {
                is_game_over = true;
                game_over();
            }

            reserve(falling_reserved);
        }
        
        private bool can_erase_row(int y) {
            for (int x = 0; x < size.x_length(); x++) {
                if (field[y, x].status == EMPTY) {
                    return false;
                }
            }
            return true;
        }
        
        private async void erase_row(bool[] v3, int bonus) {
            int middle = size.x_length() / 2;
            for (int x1 = middle, x2 = middle - 1; x1 < size.x_length(); x1++, x2--) {
                for (int y = size.y_length() - 1; y >= 0; y--) {
                    if (v3[y]) {
                        field[y, x1].status = EMPTY;
                        field[y, x2].status = EMPTY;
                        score += bonus;
                    }
                }
                changed();
                Timeout.add(20, erase_row.callback);
                yield;
            }
            score_changed(score);
        }

        private async bool move_down(int v1, int v2) {
            bool[,] checker = new bool[size.y_length(), size.x_length()];
            for (int j = v1; j >= 0; j--) {
                for (int i = 0; i < size.x_length(); i++) {
                    //print("c[%d, %d]\n", j, i);
                    if (field[j, i].status == EMPTY) {
                        //print("move down[%d, %d] => skip\n", i, j);
                        continue;
                    }
                    if (is_surrounded_by_space(j, i, checker)) {
                        int move_span = count_move_span(checker);
                        //print("move_down[%d, %d] => go_down (span = %d)\n", i, j, move_span);
                        //print_checker(checker);
                        if (move_span > 0) {
                            move_down_span(checker, move_span);
                        }
                        return false;
                    }
                    checker = new bool[size.y_length(), size.x_length()];
                }
            }
            return true;
        }
        
        private int count_move_span(bool[,] checker) {
            int move_span = 1;
            while (temp(checker, move_span)) {
                move_span++;
            }
            return move_span - 1;
        }
        
        private bool temp(bool[,] checker, int move_span) {
            for (int j = size.y_length() - 1; j >= 0; j--) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (checker[j, i]) {
                        if ((j + move_span) >= size.y_length()) {
                            return false;
                        }
                        if (field[j + move_span, i].status != EMPTY) {
                            if (!checker[j + move_span, i]) {
                                return false;
                            }
                        }
                    }
                }
            }
            return true;
        }
        
        private void move_down_span(bool[,] checker, int move_span) {
            for (int j = size.y_length() - 1; j >= 0; j--) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (checker[j, i]) {
                        field[j + move_span, i] = field[j, i];
                        field[j, i].status = EMPTY;
                    }
                }
            }
        }
        
        private bool is_surrounded_by_space(int y, int x, bool[,] checker) {
            if (field[y, x].status == EMPTY) {
                return true;
            } else if (y == size.y_length() - 1) {
                checker[y, x] = true;
                return false;
            } else {
                checker[y, x] = true;
                
                if (y == size.y_length() - 1) {
                    // do nothing.
                    return false;
                } else if (!checker[y + 1, x]) {
                    if (!is_surrounded_by_space(y + 1, x, checker)) {
                        return false;
                    }
                }
                
                if (x == size.x_length() - 1) {
                    // do nothing.
                } else if (!checker[y, x + 1]) {
                    if (!is_surrounded_by_space(y, x + 1, checker)) {
                        return false;
                    }
                }
                
                if (x == 0) {
                    // do nothing.
                } else if (!checker[y, x - 1]) {
                    if (!is_surrounded_by_space(y, x - 1, checker)) {
                        return false;
                    }
                }

                if (y == 0) {
                    // do nothing.
                } else if (!checker[y - 1, x]) {
                    if (!is_surrounded_by_space(y - 1, x, checker)) {
                        return false;
                    }
                }

                return true;
            }
        }

        private bool can_continue() {
            for (int i = 0; i < size.x_length(); i++) {
                if (field[0, i].status != EMPTY) {
                    return false;
                }
            }
            return true;
        }
    }
    
    public class GameWidget : Gtk.DrawingArea {
        public GameModel model { get; private set; }
        
        private double block_width = 20.0;
        private double block_height = 20.0;
        private double border_width = 1.0;
        private double bezel_width = 2.0;
        private double field_width;
        private double field_height;
        private Gdk.RGBA field_bgcolor = { 0.3, 0.1, 0.1, 1.0 };
        private BlockDrawer block_drawer;
        
        public GameWidget() {
            model = new GameModel(ModelSize.MODEL_10X20);
            init();
        }

        public GameWidget.with_model(GameModel model) {
            this.model = model;
            init();
        }
                
        public GameWidget.from_size(ModelSize size) {
            model = new GameModel(size);
            init();
        }
        
        private void init() {
            block_drawer = new BlockDrawer();
            block_drawer.block_width = block_width;
            block_drawer.block_height = block_height;
            block_drawer.bezel_width = bezel_width;
            block_drawer.border_width = border_width;
            field_width = (block_width + border_width) * model.size.x_length() + border_width;
            field_height = (block_height + border_width) * model.size.y_length() + border_width;
            width_request = (int) field_width;
            height_request = (int) field_height;
            queue_draw();
        }
        
        public override bool draw(Cairo.Context cairo) {
            cairo.set_source_rgba(field_bgcolor.red, field_bgcolor.green, field_bgcolor.blue, field_bgcolor.alpha);
            cairo.rectangle(0.0, 0.0, field_width, field_height);
            cairo.fill();
            Gdk.Point falling_position = model.get_falling_position();
            for (int j = 0; j < model.size.y_length(); j++) {
                for (int i = 0; i < model.size.x_length(); i++) {
                    cairo.set_source_rgba(field_bgcolor.red * 1.2, field_bgcolor.green * 1.2, field_bgcolor.blue * 1.2, 1.0);
                    cairo.arc(
                        border_width + ((block_width + border_width) * i) + (block_width / 2.0),
                        border_width + ((block_height + border_width) * j) + (block_height / 2.0),
                        2.0,
                        0.0,
                        Math.PI * 2.0
                    );
                    cairo.fill();
                    if (model.get_status(j, i) != EMPTY) {
                        block_drawer.move_to(j, i);
                        block_drawer.set_color(model.get_block_color(j, i));
                        block_drawer.draw(cairo);
                    }
                    if (model.falling.is_falling) {
                        int y = j - falling_position.y;
                        int x = i - falling_position.x;
                        if (0 <= y && y < 4 && 0 <= x && x < 4 && model.falling.data[y, x] != 0) {
                            block_drawer.move_to(j, i);
                            block_drawer.set_color(model.falling.base_color);
                            block_drawer.draw(cairo);
                        }
                    }
                }
            }
            return true;
        }
    }

    public class BlockDrawer : Object {
        public double block_width;
        public double block_height;
        public double border_width;
        public double bezel_width;
        private double x;
        private double y;
        private Gdk.RGBA color;
        
        public void move_to(int y, int x) {
            this.x = x;
            this.y = y;
        }
        
        public void set_color(Gdk.RGBA color) {
            this.color = color;
        }
        
        public void draw(Cairo.Context cairo) {
            draw_pattern(cairo);
        }
        
        public void draw_pattern(Cairo.Context cairo) {
            double x1 = border_width + (border_width + block_width) * x;
            double x2 = x1 + block_width;
            double y1 = border_width + (border_width + block_height) * y;
            double y2 = y1 + block_height;
            double x0 = x1 + block_width / 2;
            double y0 = y1 + block_height / 2;

            double brightness = 1.5;
            cairo.set_source_rgba(color.red * brightness, color.green * brightness, color.blue * brightness, color.alpha);
            cairo.move_to(x0, y0);
            cairo.line_to(x1, y1);
            cairo.line_to(x2, y1);
            cairo.fill();

            brightness = 1.3;
            cairo.set_source_rgba(color.red * brightness, color.green * brightness, color.blue * brightness, color.alpha);
            cairo.move_to(x0, y0);
            cairo.line_to(x1, y1);
            cairo.line_to(x1, y2);
            cairo.fill();
            
            brightness = 0.8;
            cairo.set_source_rgba(color.red * brightness, color.green * brightness, color.blue * brightness, color.alpha);
            cairo.move_to(x0, y0);
            cairo.line_to(x2, y1);
            cairo.line_to(x2, y2);
            cairo.fill();
            
            brightness = 0.5;
            cairo.set_source_rgba(color.red * brightness, color.green * brightness, color.blue * brightness, color.alpha);
            cairo.move_to(x0, y0);
            cairo.line_to(x1, y2);
            cairo.line_to(x2, y2);
            cairo.fill();
            
            cairo.rectangle(x1 + bezel_width, y1 + bezel_width, block_width - bezel_width * 2, block_height - bezel_width * 2);
            cairo.set_source_rgba(color.red, color.green, color.blue, 0.7);
            cairo.fill();
        }
    }
    
    public class ReservedDisplayWidget : Gtk.DrawingArea {
        public FallingBlock? blocks { get; set; }
        public Gdk.RGBA bgcolor = { 0.3, 0.1, 0.1, 1.0 };
        public BlockDrawer block_drawer;

        public ReservedDisplayWidget(double block_width, double block_height, double border_width, double bezel_width) {
            block_drawer = new BlockDrawer();
            block_drawer.block_width = block_width;
            block_drawer.block_height = block_height;
            block_drawer.border_width = border_width;
            block_drawer.bezel_width = bezel_width;
            height_request = (int) ((block_height + border_width) * 4 + border_width);
            width_request = (int) ((block_height + border_width) * 4 + border_width);
        }
        
        public override bool draw(Cairo.Context cairo) {
            cairo.set_source_rgba(bgcolor.red, bgcolor.green, bgcolor.blue, bgcolor.alpha);
            cairo.rectangle(0.0, 0.0, (double) width_request, (double) height_request);
            cairo.fill();
            
            if (blocks != null) {
                for (int j = 0; j < 4; j++) {
                    for (int i = 0; i < 4; i++) {
                        if (blocks.data[j, i] != 0) {
                            block_drawer.move_to(j, i);
                            block_drawer.set_color(blocks.base_color);
                            block_drawer.draw(cairo);
                        }
                    }
                }
            }
            return true;
        }
    }
}

Gtk.ApplicationWindow create_window(Gtk.Application app) {
    try {
        var ahoris_model = new Ahoris.GameModel(MODEL_10X20);
        var window = new Gtk.ApplicationWindow(app);
        {
            var headerbar = new Gtk.HeaderBar();
            {
                var title_logo = new Gtk.Image.from_resource("/images/title-logo.svg");
                headerbar.custom_title = title_logo;
            }

            var hbox1 = new Gtk.Box(HORIZONTAL, 8);
            {            
                var ahoris_widget = new Ahoris.GameWidget.with_model(ahoris_model);
                {
                    ahoris_model.changed.connect(() => {
                        ahoris_widget.queue_draw();
                    });

                }

                var vbox1 = new Gtk.Box(VERTICAL, 8);
                {
                    var score_board = new Gtk.Label("Score: 0");
                    {
                        ahoris_model.score_changed.connect((score) => {
                            score_board.label = @"Score: $(score)";
                            score_board.queue_draw();
                        });
                    }

                    var reserved_display = new Ahoris.ReservedDisplayWidget(20.0, 20.0, 1.0, 2.0);
                    {
                        ahoris_model.reserve.connect((reserved_blocks) => {
                            reserved_display.blocks = reserved_blocks;
                            reserved_display.queue_draw();
                        });
                        Idle.add(() => {
                            reserved_display.width_request = vbox1.get_allocated_width();
                            return false;
                        });
                    }

                    var description_grid = new Gtk.Grid();
                    {
                        var image_left = new Gtk.Image();
                        {
                            var pixbuf_left = new Gdk.Pixbuf.from_resource_at_scale("/images/left.svg", 16, 16, true);
                            image_left.pixbuf = pixbuf_left;
                        }

                        var description_left = new Gtk.Label("左に動かす");

                        var image_right = new Gtk.Image();
                        {
                            var pixbuf_right = new Gdk.Pixbuf.from_resource_at_scale("/images/right.svg", 16, 16, true);
                            image_right.pixbuf = pixbuf_right;
                        }

                        var description_right = new Gtk.Label("右に動かす");

                        var image_up = new Gtk.Image();
                        {
                            var pixbuf_up = new Gdk.Pixbuf.from_resource_at_scale("/images/up.svg", 16, 16, true);
                            image_up.pixbuf = pixbuf_up;
                        }

                        var description_up = new Gtk.Label("左回り");

                        var image_down = new Gtk.Image();
                        {
                            var pixbuf_down = new Gdk.Pixbuf.from_resource_at_scale("/images/down.svg", 16, 16, true);
                            image_down.pixbuf = pixbuf_down;
                        }

                        var description_down = new Gtk.Label("右回り");

                        var label_enter = new Gtk.Label("<b>Enter</b>") { use_markup = true };
                        var description_enter = new Gtk.Label("加速する");

                        description_grid.attach(image_left, 0, 0);
                        description_grid.attach(description_left, 1, 0);
                        description_grid.attach(image_right, 0, 1);
                        description_grid.attach(description_right, 1, 1);
                        description_grid.attach(image_up, 0, 2);
                        description_grid.attach(description_up, 1, 2);
                        description_grid.attach(image_down, 0, 3);
                        description_grid.attach(description_down, 1, 3);
                        description_grid.attach(label_enter, 0, 4);
                        description_grid.attach(description_enter, 1, 4);
                        description_grid.row_spacing = 8;
                        description_grid.column_spacing = 4;
                    }

                    var reset_button = new Gtk.Button.with_label("リセットする");
                    {
                        reset_button.clicked.connect(() => {
                            create_window(app);
                            window.close();
                        });
                    }

                    var exit_button = new Gtk.Button.with_label("終了する");
                    {
                        exit_button.clicked.connect(() => {
                            Process.exit(0);
                        });
                    }

                    vbox1.pack_start(score_board, false, false);
                    vbox1.pack_start(reserved_display, false, false);
                    vbox1.pack_start(description_grid, false, false);
                    vbox1.pack_end(exit_button, false, false);
                    vbox1.pack_end(reset_button, false, false);
                    vbox1.height_request = ahoris_widget.height_request;
                }

                hbox1.pack_start(ahoris_widget, false, false);
                hbox1.pack_start(vbox1, false, false);
                hbox1.margin = 6;
            }

            ahoris_model.game_over.connect(() => {
                var dialog = new Gtk.MessageDialog(window, MODAL, INFO, OK, "はいゲーム終了");
                dialog.run();
                dialog.close();
            });
            window.set_titlebar(headerbar);
            window.add(hbox1);
            window.add_events(Gdk.EventMask.KEY_PRESS_MASK);
            window.key_press_event.connect((event) => {
                if (ahoris_model.is_running) {
                    switch (event.keyval) {
                      case Gdk.Key.Up:
                        ahoris_model.turn_left();
                        break;
                      case Gdk.Key.Down:
                        ahoris_model.turn_right();
                        break;
                      case Gdk.Key.Right:
                        ahoris_model.go_right();
                        break;
                      case Gdk.Key.Left:
                        ahoris_model.go_left();
                        break;
                      case Gdk.Key.Return:
                        try {
                            ahoris_model.go_down_fast();
                        } catch (Ahoris.GameError e) {
                            printerr(@"$(e.message)\n");
                            window.close();
                            app.quit();
                        }
                        break;
                      default:
                        return false;
                    }
                    return true;
                }
                return false;
            });
        }
        window.show_all();
        ahoris_model.start.begin();
        return window;
    } catch (GLib.Error e) {
        printerr(@"ERROR: $(e.message)\n");
        Process.exit(e.code);
    }
    
}

int main(string[] argv) {
    Random.set_seed((uint32) new DateTime.now_utc().to_unix());
    var app = new Gtk.Application("com.github.aharotias2.Ahoris", FLAGS_NONE);
    app.activate.connect(() => {
        create_window(app);
    });
    return app.run(argv);
}
