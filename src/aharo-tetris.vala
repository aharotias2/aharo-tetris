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

namespace AharoTetris {
    /**
     * エラーを定義します。基本的に異常終了判定にのみ使用します。
     * つまり基本的に発生しない想定
     */
    public errordomain GameError {
        /** プログラムのロジックに矛盾があり、通れないはずのフローに入った場合、この例外を投げる。 */
        LOGICAL_ERROR
    }

    /**
     * モデルのサイズはゲームフィールドの縦と横の長さを定義します。
     * 横10縦20しか使っていませんが特に意味もなく15x30も用意しています(使っていません)。
     */
    public enum ModelSize {
        /**
         * 縦20、横10のモデル
         */
        MODEL_10X20,

        /**
         * 縦30、横15のモデル (使っていない)
         */
        MODEL_15X30;

        /**
         * 横の「マス」の数を返します。(通常10)
         */
        public int x_length() {
            switch (this) {
              default:
              case MODEL_10X20:
                return 10;
              case MODEL_15X30:
                return 15;
            }
        }

        /**
         * 縦の「マス」の数を返します。(通常20)
         */
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

    /**
     * 得点ルール
     */
    namespace Score {
        /**
         * 一行消した場合 (シングル)
         */
        public const int SINGLE = 40;
        
        /**
         * 二行消した場合 (ダブル)
         */
        public const int DOUBLE = 100;

        /**
         * 三行消した場合 (トリプル)
         */
        public const int TRIPLE = 300;

        /**
         * 四行消した場合 (テトリス)
         */
        public const int TETRIS = 1200;

        /**
         * 五行以上消した場合
         */
        public const int SUPER = 2000;
        
        /**
         * シングルとダブルを同時
         */
        public const int ONE_TWO = 1000;

        /**
         * 二つのシングル (一行開け)
         */
        public const int SINGLE_SPLIT = 600;

        /**
         * 二つのシングル (二行開け)
         */
        public const int DOUBLE_SPLIT = 900;
    }

    /**
     * フィールド内の状態を表します。
     */
    public enum FieldStatus {
        /**
         * 空である。(ブロックが置かれていない)
         */
        EMPTY,

        /**
         * ブロックが置かれている。
         */
        BLOCKED,

        /**
         * 行が消える時にはフラッシュ効果のためこの状態にする。
         */
        LIGHTING;
    }

    /**
     * 落ちてくるブロックが置かれているブロックと重なっているかどうか、
     * あるいはフィールドからはみ出していないかどうかの状態を表す。
     */
    public enum OverlappingState {
        /**
         * 落ちてくるブロックが置かれているブロックに重なっていない状態
         */
        NOT_OVERLAPPED,

        /**
         * 落ちてくるブロックがフィールドの左にはみ出している状態
         */
        OVER_LEFT,

        /**
         * 落ちてくるブロックがフィールドに置かれたブロックと重なっている状態
         */
        OVERLAPPED,

        /**
         * 落ちてくるブロックがフィールドの右にはみ出している状態
         */
        OVER_RIGHT
    }

    /**
     * フィールドの各位置の状態を保持する。
     */
    public struct FieldBlock {
        /**
         * 状態
         */
        public FieldStatus status;

        /**
         * ブロックが置かれている場合、そのブロックの色を表す
         */
        public Gdk.RGBA base_color;
    }

    /**
     * 落ちているブロックの状態を保持する。
     */
    public class FallingBlock {
        /**
         * 落ちているブロック縦横の最大長。
         */
        public int length;

        /**
         * 落ちているブロックの形状を表す
         * 1はブロックがある状態、0はブロックがない状態を表す
         */
        public uint8[,] data;

        /**
         * 落ちているブロックの色を保持する
         */
        public Gdk.RGBA base_color;

        /**
         * 落ちているブロックのxy座標を表す
         */
        public Gdk.Point position;

        /**
         * 落ちているブロックが着地していない場合true、着地した場合はfalse
         */
        public bool is_falling;

        /**
         * 形状の番号を指定して落ちているブロックを作成する
         */
        public FallingBlock(int pattern_num) {
            init(pattern_num);
        }

        /**
         * ランダムな形状の落ちているブロックを作成する
         */
        public FallingBlock.random_pattern() {
            init(Random.int_range(0, 7));
        }

        /**
         * 引数origと同じ状態のインスタンスを作成する
         */
        public FallingBlock.clone_of(FallingBlock orig) {
            data = new uint8[orig.length, orig.length];
            length = orig.length;
            base_color = orig.base_color;
            position = orig.position;
            for (int j = 0; j < orig.length; j++) {
                for (int i = 0; i < orig.length; i++) {
                    data[j, i] = orig.data[j, i];
                }
            }
            is_falling = orig.is_falling;
        }

        private void init(int pattern_num) {
            // 落ちているブロックの形状を決定する
            uint8[,] ptr;
            switch (pattern_num % 7) {
              default:
              case 0:
                // Iシェイプ (水色)
                ptr = {
                    {0, 0, 0, 0},
                    {1, 1, 1, 1},
                    {0, 0, 0, 0},
                    {0, 0, 0, 0}
                };
                base_color = { 0.50, 0.60, 0.80, 1.0 };
                length = 4;
                break;
              case 1:
                // Zシェイプ (赤)
                ptr = {
                    {0, 0, 0},
                    {1, 1, 0},
                    {0, 1, 1},
                };
                base_color = { 0.75, 0.25, 0.25, 1.0 };
                length = 3;
                break;
              case 2:
                // Sシェイプ (緑)
                ptr = {
                    {0, 0, 0},
                    {0, 1, 1},
                    {1, 1, 0},
                };
                base_color = { 0.35, 0.60, 0.40, 1.0 };
                length = 3;
                break;
              case 3:
                // Jシェイプ (青)
                ptr = {
                    {0, 1, 1},
                    {0, 1, 0},
                    {0, 1, 0}
                };
                base_color = { 0.25, 0.25, 0.75, 1.0 };
                length = 3;
                break;
              case 4:
                // Lシェイプ (オレンジ)
                ptr = {
                    {1, 1, 0},
                    {0, 1, 0},
                    {0, 1, 0}
                };
                base_color = { 0.75, 0.50, 0.25, 1.0 };
                length = 3;
                break;
              case 5:
                // Oシェイプ (黄色)
                ptr = {
                    {1, 1},
                    {1, 1},
                };
                base_color = { 0.75, 0.75, 0.25, 1.0 };
                length = 2;
                break;
              case 6:
                // Tシェイプ (紫)
                ptr = {
                    {0, 0, 0},
                    {1, 1, 1},
                    {0, 1, 0},
                };
                base_color = { 0.75, 0.25, 0.60, 1.0 };
                length = 3;
                break;
            }

            // dataにパターンをコピーする
            data = new uint8[length, length];
            for (int y = 0; y < length; y++) {
                for (int x = 0; x < length; x++) {
                    data[y, x] = ptr[y, x];
                }
            }

            // ランダムな回数分、回転する。
            int random_value = Random.int_range(0, 4);
            for (int i = 0; i < random_value; i++) {
                rotate_right();
            }

            is_falling = true;
        }

        /**
         * 落ちているブロックを時計回りに回転させる
         */
        public void rotate_right() {
            uint8[,] tmp = new uint8[length, length];
            for (int y = 0; y < length; y++) {
                for (int x = 0; x < length; x++) {
                    tmp[x, length - (y + 1)] = data[y, x];
                }
            }
            for (int y = 0; y < length; y++) {
                for (int x = 0; x < length; x++) {
                    data[y, x] = tmp[y, x];
                }
            }
        }

        /**
         * 落ちているブロックを反時計回りに回転させる
         */
        public void rotate_left() {
            uint8[,] tmp = new uint8[length, length];
            for (int y = 0; y < length; y++) {
                for (int x = 0; x < length; x++) {
                    tmp[length - (x + 1), y] = data[y, x];
                }
            }
            for (int y = 0; y < length; y++) {
                for (int x = 0; x < length; x++) {
                    data[y, x] = tmp[y, x];
                }
            }
        }
    }

    /**
     * ゲームの状態を管理するオブジェクトのクラス
     */
    public class GameModel : Object {
        public signal void reserve(FallingBlock falling_reserved);
        public signal void changed();
        public signal void score_changed(int current_score, int new_score, int bonus);
        public signal void lines_changed(int current_lines, int new_lines);
        public signal void level_changed(int level);
        public signal void game_over();

        public int lines { get; private set; default = 0; }
        public ModelSize size { get; private set; }
        public int level { get; private set; default = 1; }
        public int speed { get; set; default = 60; }
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
        private int waiting_count;
        private int additional_score;

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

        /**
         * ゲームルーチンを開始するメソッド
         * 終了するまで、非同期的に動作し続ける。
         */
        public async void start() throws GameError {
            falling = new FallingBlock.random_pattern();
            falling.position = Gdk.Point() {
                x = size.x_length() / 2 - 2,
                y = -falling.length
            };
            falling_reserved = new FallingBlock.random_pattern();
            falling_reserved.position = Gdk.Point() {
                x = size.x_length() / 2 - 2,
                y = -falling.length
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
                Timeout.add(60000 / (speed + (level - 1) * 2), start.callback);
                yield;
            } while (!is_game_over);
            game_over();
        }

        public void force_exit() {
            is_game_over = true;
        }

        /**
         * ゲームフィールドをリセットする。
         */
        public void reset_by_size(ModelSize size) {
            this.size = size;
            this.field = new FieldBlock[size.y_length(), size.x_length()];
        }

        /**
         * 落ちているブロックを反時計周りに90°回転させる
         */
        public void turn_left() {
            // 最初の状態を保存する
            var save_falling = new FallingBlock.clone_of(falling);
            falling.rotate_left();
            while (true) {
                switch (is_overlapped()) {
                  case OVERLAPPED:
                    // 重なっている場合、保存した状態に戻す (回転しない)
                    falling = save_falling;
                    return;
                  case OVER_LEFT:
                    if (can_go_right()) {
                        // 左にはみ出して右に移動できる場合は右に移動する
                        go_right();
                    } else {
                        // 左にはみ出して右に移動できない場合は回転しない (保存した状態に戻す)
                        falling = save_falling;
                        return;
                    }
                    break;
                  case OVER_RIGHT:
                    if (can_go_left()) {
                        // 右にはみ出して左に移動できる場合は左に移動する
                        go_left();
                    } else {
                        // 右にはみ出して左に移動できない場合は保存した状態に戻す (回転しない)
                        falling = save_falling;
                        return;
                    }
                    break;
                  default:
                    // それ以外の場合は反時計回り90°回転だけする
                    changed();
                    return;
                }
            }
        }

        /**
         * 落ちているブロックを時計回りに90°回転させる
         */
        public void turn_right() {
            // 最初の状態を保存する
            var save_falling = new FallingBlock.clone_of(falling);
            falling.rotate_right();
            while (true) {
                switch (is_overlapped()) {
                  case OVERLAPPED:
                    // 重なっている場合、保存した状態に戻す (回転しない)
                    falling = save_falling;
                    return;
                  case OVER_LEFT:
                    if (can_go_right()) {
                        // 左にはみ出して右に移動できる場合は右に移動する
                        go_right();
                    } else {
                        // 左にはみ出して右に移動できない場合は回転しない (保存した状態に戻す)
                        falling = save_falling;
                        return;
                    }
                    break;
                  case OVER_RIGHT:
                    if (can_go_left()) {
                        // 右にはみ出して左に移動できる場合は左に移動する
                        go_left();
                    } else {
                        // 右にはみ出して左に移動できない場合は保存した状態に戻す(回転しない)
                        falling = save_falling;
                        return;
                    }
                    break;
                  default:
                    // それ以外の場合は時計回り90°回転だけする。
                    changed();
                    return;
                }
            }
        }

        /**
         * 一段下に下がる
         */
        public void go_down_fast() throws GameError {
            if (is_paused) {
                return;
            }

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

        /**
         * 左に移動する
         */
        public void go_left() {
            if (can_go_left()) {
                falling.position.x--;
                changed();
            }
        }

        /**
         * 右に移動する
         */
        public void go_right() {
            if (can_go_right()) {
                falling.position.x++;
                changed();
            }
        }

        /**
         * 落ちているブロックが下に移動できるかを判定する
         */
        private bool can_go_down() {
            for (int j = falling.length - 1; j >= 0; j--) {
                for (int i = 0; i < falling.length; i++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    // 画面の上にはみ出すところは判定しない
                    if (y < 0) {
                        continue;
                    }
                    if (falling.data[j, i] != 0) {
                        // フィールドの一番下に着地している場合は移動できない
                        if (y + 1 >= size.y_length()) {
                            return false;
                        }
                        if (field[y + 1, x].status != EMPTY) {
                            // 置いてあるブロックと重なる場合も移動できない
                            return false;
                        }
                    }
                }
            }
            // それ以外の場合は移動できる。
            return true;
        }

        /**
         * 落ちているブロックが左に移動できるかを判定する。
         */
        private bool can_go_left() {
            for (int i = 0; i < falling.length; i++) {
                for (int j = falling.length - 1; j >= 0; j--) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (falling.data[j, i] != 0) {
                        if (y >= 0 && field[y, x - 1].status != EMPTY) {
                            // 置いてあるブロックと重なる場合は移動できない
                            return false;
                        }
                        if (x == 0) {
                            // フィールドの左にはみ出す場合も移動できない
                            return false;
                        }
                    }
                }
            }
            // それ以外の場合は移動できる
            return true;
        }

        /**
         * 落ちているブロックが右に移動できるかを判定する
         */
        private bool can_go_right() {
            for (int i = falling.length - 1; i >= 0; i--) {
                for (int j = 0; j < falling.length; j++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (falling.data[j, i] != 0) {
                        if (y >= 0 && field[y, x + 1].status != EMPTY) {
                            // 置いてあるブロックと重なる場合は移動できない
                            return false;
                        }
                        if (x == size.x_length() - 1) {
                            // フィールドの右にはみ出す場合も移動できない
                            return false;
                        }
                    }
                }
            }
            // それ以外の場合は移動できる
            return true;
        }

        /**
         * 落ちているブロックが置いてあるブロックと重なるところがあるかを判定する
         * あるいは、フィールドの左右にはみ出していないかも判定する。
         *
         * OverlappingState.OVER_LEFT: 左にはみ出している
         * OverlappingState.OVERRIGHT: 右にはみ出している
         * OverlappingState.OVERLAPPED: 置いてあるブロックと重なっている
         * OverlappingState.NOT_OVERLAPPED: 重なっておらず、はみ出してもいない
         */
        private OverlappingState is_overlapped() {
            for (int j = 0; j < falling.length; j++) {
                for (int i = 0; i < falling.length; i++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (falling.data[j, i] != 0) {
                        if (x < 0) {
                            return OVER_LEFT;
                        } else if (x >= size.x_length()) {
                            return OVER_RIGHT;
                        } else if (y >= 0 && field[y, x].status != EMPTY) {
                            return OVERLAPPED;
                        }
                    }
                }
            }
            return NOT_OVERLAPPED;
        }

        /**
         * 落ちているブロックを固定する。
         * 固定し終わったら消して良い行があるか判定して、
         * 消して良い行がある場合は消す処理を行う。
         */
        private async void fix_falling() throws GameError {
            // 落ちているブロックのステータスを置いてあるブロックに写す。
            for (int j = 0; j < falling.length; j++) {
                for (int i = 0; i < falling.length; i++) {
                    int y = falling.position.y + j;
                    int x = falling.position.x + i;
                    if (y < 0) {
                        // フィールドからはみ出す部分はスキップする
                        continue;
                    }
                    if (field[y, x].status != EMPTY && falling.data[j, i] != 0) {
                        // 落ちているブロックと置いてあるブロックが重なっているとき
                        // 正しくコーディングできていればこのフローは通らないので例外とする。(強制終了)
                        assert_not_reached();
                    }
                    // 固定処理
                    if (falling.data[j, i] != 0) {
                        field[y, x] = FieldBlock() {
                            status = BLOCKED,
                            base_color = falling.base_color
                        };
                        score += level;
                        score_changed(score, 1, level);
                    }
                }
            }

            // 新しく落ちてくるブロックを生成する
            falling.is_falling = false;
            falling = falling_reserved;
            falling_reserved = new FallingBlock.random_pattern();
            falling_reserved.position = { size.x_length() / 2 - 2, -falling.length };
            changed();
            Idle.add(fix_falling.callback);
            yield;

            // 行を消す処理を開始する。

            bool is_erased = false;
            int bonus = 1;

            while (true) {
                // 消す行があるかどうかのフラグ
                is_erased = false;

                // 消す行をtrueにして後で使う
                bool[] selection = new bool[size.y_length()];

                // 消せる行を探してselectionを設定する
                for (int j = size.y_length() - 1; j >= 0; j--) {
                    if (can_erase_row(j)) {
                        selection[j] = true;

                        // 消せる行が増えるとボーナス得点になる (仕様がよく決まってない)
                        //bonus++;

                        is_erased = true;
                    }
                }

                if (!is_erased) {
                    // 消す行がなくなったらループを抜ける。
                    break;
                }

                // 行を消す時はチカチカエフェクトなどがあるので非同期で呼び出す
                yield erase_row(selection, bonus);

                // 状態の変更がある時はchangedシグナルを出す
                changed();
                Timeout.add(10, fix_falling.callback);
                yield;

                // 全ての移動が完了したときにtrueにするフラグ
                bool move_completed = false;

                // まず落下できるブロックかどうかを判定する
                // その時何度も同じブロックを検査しないように検査したブロックの位置をmemoに保存する
                bool[,] memo = new bool[size.y_length(), size.x_length()];

                waiting_count = 0;

                additional_score = 0;

                // 行が消えたことで落ちるブロックを探索する
                while (!move_completed) {
                    move_completed = go_down(memo);
                }

                Idle.add(fix_falling.callback);
                yield;

                // 全ての落下が完了するまで待つ
                while (waiting_count > 0) {
                    Timeout.add(30, fix_falling.callback);
                    yield;
                }

                changed();

                score += additional_score;
                score_changed(score, additional_score, 1);

                Timeout.add(250, fix_falling.callback);
                yield;

                // ボーナス得点を加算する (このところの仕様はよく決まってない)
                bonus *= 2;

            }

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

        /**
         * 引数selectionによって選択された行を消す。
         * 消す時にチカチカするエフェクトをかける。
         */
        private async void erase_row(bool[] selection, int bonus) {
            // チカチカエフェクト
            bool onoff = true;
            for (int i = 0; i < 5; i++) {
                for (int j = 0; j < size.y_length(); j++) {
                    if (selection[j]) {
                        for (int x = 0; x < size.x_length(); x++) {
                            field[j, x].status = onoff ? FieldStatus.LIGHTING : FieldStatus.BLOCKED;
                        }
                    }
                }
                onoff = !onoff;
                changed();
                Timeout.add(100, erase_row.callback);
                yield;
            }

            // 行を消す
            int n1 = 0;
            int n2 = 0;
            int n3 = 0;
            int middle = size.x_length() / 2;
            for (int x1 = middle, x2 = middle - 1; x1 < size.x_length(); x1++, x2--) {
                for (int y = size.y_length() - 1; y >= 0; y--) {
                    if (selection[y]) {
                        field[y, x1].status = EMPTY;
                        field[y, x2].status = EMPTY;
                        if (x2 == 0) {
                            n1++;
                            if (n2 > 0) {
                                n3++;
                            }
                        }
                    } else if (x2 == 2 && n1 > 0) {
                        n2++;
                    }
                }
                changed();
                Timeout.add(20, erase_row.callback);
                yield;
            }
            // スコア加算処理
            int new_score = 0;
            if (n1 == 1) {
                // 一行消した場合
                new_score = Score.SINGLE;
            } else if (n3 == 0) {
                if (n1 == 2) {
                    // 二行消した場合
                    new_score = Score.DOUBLE;
                } else if (n1 == 3) {
                    // 三行消した場合
                    new_score = Score.TRIPLE;
                } else if (n1 == 4) {
                    // 四行消した場合
                    new_score = Score.TETRIS;
                }
            } else if (n3 == 1) {
                if (n1 == 2) {
                    // 二行消して1行間に開けた場合
                    new_score = Score.SINGLE_SPLIT;
                } else if (n1 == 3) {
                    // 三行消して1行間に開けた場合
                    new_score = Score.ONE_TWO;
                }
            } else if (n3 == 2) {
                // 二行消して2行間に開けた場合
                new_score = Score.DOUBLE_SPLIT;
            }
            if (n1 > 4) {
                // 五行以上消した場合
                new_score = Score.SUPER * n1;
            }
            // 以上の基本点にレベルとボーナスをかける (ボーナスは連鎖消しをすると増える)
            score += new_score * level * bonus;
            score_changed(score, new_score, bonus);
            lines += n1;
            if ((lines / 10) >= level) {
                level++;
                level_changed(level);
            }
            lines_changed(lines, n1);
        }

        /**
         * 落ちているブロックを落下させる
         * 正確には落下の「予約」をする。
         * あとで非同期的に落下させる
         */
        private bool go_down(bool[,] memo) {
            bool[,] checker = new bool[size.y_length(), size.x_length()];
            for (int j = size.y_length() - 1; j >= 0; j--) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (field[j, i].status == EMPTY) {
                        // ブロックがないところは飛ばす
                        continue;
                    }
                    if (memo[j, i]) {
                        // 検査済みは飛ばす
                        continue;
                    }
                    if (is_surrounded_by_space(j, i, checker)) {
                        waiting_count++;
                        overwrite_memo(memo, checker);
                        // ここでTimeoutを使う理由は先に落下させてしまうと他の位置にある落下させられるブロック
                        // に触れてしまう場合、それを止めてしまうので、
                        // 予約しておくことで行が消えた時点で浮いている全てのブロックを確実に落下させるため。
                        // また、そうすることで浮いているブロックの塊が何個あってもそれぞれ独立して落ちるので、
                        // 連鎖反応を起こすことができるようになる。
                        Timeout.add(30, () => {
                            go_down_once(checker);
                            changed();
                            if (can_go_down_once(checker)) {
                                return true;
                            } else {
                                waiting_count--;
                                return false;
                            }
                        });
                        return false;
                    }
                    checker = new bool[size.y_length(), size.x_length()];
                }
            }
            return true;
        }

        // 検査済みのブロックの位置をマークする。(マーク済みのリストに追加する)
        private void overwrite_memo(bool[,] memo, bool[,] checker) {
            for (int j = 0; j < size.y_length(); j++) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (checker[j, i]) {
                        memo[j, i] = true;

                        // 行を消した時、上に乗っていたブロックの数が多いほど
                        // 得点を高くする。
                        additional_score += level;
                    }
                }
            }
        }

        // 落ちているブロックを一段下に下げる。
        private void go_down_once(bool[,] checker) {
            for (int j = size.y_length() - 1; j >= 0; j--) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (checker[j, i]) {
                        field[j + 1, i] = field[j, i];
                        field[j, i].status = EMPTY;
                        checker[j + 1, i] = true;
                        checker[j, i] = false;
                    }
                }
            }
        }

        /**
         * 落ちているブロックの塊が一段下へ下がることができるかどうかを判定する
         * true: 下がることができる
         * false: 下がることができない
         */
        private bool can_go_down_once(bool[,] checker) {
            for (int j = size.y_length() - 1; j >= 0; j--) {
                for (int i = 0; i < size.x_length(); i++) {
                    if (checker[j, i]) {
                        // 既に着地している場合はfalse
                        if ((j + 1) >= size.y_length()) {
                            return false;
                        }
                        // 一段下にブロックが置かれている場合もfalse
                        if (field[j + 1, i].status != EMPTY) {
                            if (!checker[j + 1, i]) {
                                return false;
                            }
                        }
                    }
                }
            }
            // falseとなる条件が一つもなければtrue
            return true;
        }

        /**
         * ブロックが宙に浮いているかどうかを判定する
         * 宙に浮いている場合true
         * 浮いていない場合false
         *
         * 最初の呼び出しの時はy, x地点の状態がEMPTYでないことが必要。
         */
        private bool is_surrounded_by_space(int y, int x, bool[,] checker) {
            if (field[y, x].status == EMPTY) {
                // ここには再帰呼び出しでのみ来る
                return true;
            } else if (checker[y, x]) {
                // 検査済みの場合はtrueを返す
                return true;
            } else if (y == size.y_length() - 1) {
                // ブロックが着地している場合、浮いていない判定になる。
                checker[y, x] = true;
                return false;
            } else {
                checker[y, x] = true;

                // 下を検査する
                if (y == size.y_length() - 1) {
                    // 着地している場合、浮いていない判定になる
                    return false;
                } else if (!is_surrounded_by_space(y + 1, x, checker)) {
                    // このブロックに隣接するブロックを再帰的に辿っていき
                    // 着地した場合は浮いていない判定となる。
                    // 他の方向への検査の場合も同様
                    return false;
                }

                // 右を検査する
                if (x == size.x_length() - 1) {
                    // ブロックが右端にある場合、検査しない
                } else if (!is_surrounded_by_space(y, x + 1, checker)) {
                    return false;
                }

                // 左を検査する
                if (x == 0) {
                    // ブロックが左端にある場合、検査しない
                } else if (!is_surrounded_by_space(y, x - 1, checker)) {
                    return false;
                }

                // 上を検査する
                if (y == 0) {
                    // ブロックが上限にある場合は検査しない
                } else if (!is_surrounded_by_space(y - 1, x, checker)) {
                    return false;
                }

                // 上下左右どの方向から辿っても着地しない場合は浮いている判定となる
                return true;
            }
        }

        /**
         * ブロックが上限に達していないことを判定する
         * true: ブロックが上限に達していない
         * false: ブロックが上限に達している
         */
        private bool can_continue() {
            for (int i = 0; i < size.x_length(); i++) {
                if (field[0, i].status != EMPTY) {
                    return false;
                }
            }
            return true;
        }
    }

    /**
     * ゲーム画面を描画するウィジェット
     */
    public class GameWidget : Gtk.DrawingArea {
        public GameModel model { get; private set; }

        private double block_width = 20.0;
        private double block_height = 20.0;
        private double border_width = 1.0;
        private double bezel_width = 2.0;
        private double field_width;
        private double field_height;
        private Gdk.RGBA field_bgcolor = { 0.1, 0.1, 0.1, 1.0 };
        private Gdk.RGBA dot_color = { 0.5, 0.5, 0.5, 0.25 };
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
            // フィールド全体を塗りつぶす
            cairo.set_source_rgba(field_bgcolor.red, field_bgcolor.green, field_bgcolor.blue, field_bgcolor.alpha);
            cairo.rectangle(0.0, 0.0, field_width, field_height);
            cairo.fill();
            Gdk.Point falling_position = model.get_falling_position();
            for (int j = 0; j < model.size.y_length(); j++) {
                for (int i = 0; i < model.size.x_length(); i++) {
                    if (model.get_status(j, i) == EMPTY) {
                        if (model.falling.is_falling) {
                            // 落ちているブロックを描写する
                            int y = j - falling_position.y;
                            int x = i - falling_position.x;
                            if (0 <= y && y < model.falling.length && 0 <= x && x < model.falling.length && model.falling.data[y, x] != 0) {
                                block_drawer.move_to(j, i);
                                block_drawer.set_color(model.falling.base_color);
                                block_drawer.draw(cairo);
                                continue;
                            }
                        }
                        // 各位置の背景にあるドットを描写する
                        cairo.set_source_rgba(dot_color.red, dot_color.green, dot_color.blue, dot_color.alpha);
                        cairo.arc(
                            border_width + ((block_width + border_width) * i) + (block_width / 2.0),
                            border_width + ((block_height + border_width) * j) + (block_height / 2.0),
                            2.0,
                            0.0,
                            Math.PI * 2.0
                        );
                        cairo.fill();
                    } else {
                        // 置かれているブロックを描写する
                        block_drawer.move_to(j, i);
                        // 行が消える時にチカチカするエフェクトを描写する
                        if (model.get_status(j, i) == LIGHTING) {
                            block_drawer.set_color({1.0, 1.0, 1.0, 1.0});
                        } else {
                            block_drawer.set_color(model.get_block_color(j, i));
                        }
                        block_drawer.draw(cairo);
                    }
                }
            }
            return true;
        }
    }

    /**
     * ブロックをひとつ描画するヘルパークラス
     */
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

            cairo.set_source_rgba(color.red, color.green, color.blue, 1.0);
            cairo.rectangle(x1, y1, block_width, block_height);
            cairo.fill();

            cairo.set_source_rgba(1.0, 1.0, 1.0, 0.75);
            cairo.move_to(x0, y0);
            cairo.line_to(x1, y1);
            cairo.line_to(x2, y1);
            cairo.fill();

            cairo.set_source_rgba(1.0, 1.0, 1.0, 0.5);
            cairo.move_to(x0, y0);
            cairo.line_to(x1, y1);
            cairo.line_to(x1, y2);
            cairo.fill();

            cairo.set_source_rgba(0.0, 0.0, 0.0, 0.25);
            cairo.move_to(x0, y0);
            cairo.line_to(x2, y1);
            cairo.line_to(x2, y2);
            cairo.fill();

            cairo.set_source_rgba(0.0, 0.0, 0.0, 0.5);
            cairo.move_to(x0, y0);
            cairo.line_to(x1, y2);
            cairo.line_to(x2, y2);
            cairo.fill();

            double x3 = x1 + bezel_width;
            double x4 = block_width - bezel_width * 2;
            double y3 = y1 + bezel_width;
            double y4 = block_height - bezel_width * 2;
            
            Cairo.Pattern pat1 = new Cairo.Pattern.linear(x3, y3, x3 + x4, y3 + y4);
            pat1.add_color_stop_rgba(1, color.red * 0.75, color.green * 0.75, color.blue * 0.75, color.alpha);
            pat1.add_color_stop_rgba(0, color.red * 1.50, color.green * 1.50, color.blue * 1.50, color.alpha);
            cairo.set_source(pat1);
            cairo.rectangle(x3, y3, x4, y4);
            cairo.fill();

            Cairo.Pattern pat2 = new Cairo.Pattern.linear(x3, y3, x3 + x4, y3 + y4);
            pat2.add_color_stop_rgba(1, 1.0, 1.0, 1.0, 0.5);
            pat2.add_color_stop_rgba(0.5, 1.0, 1.0, 1.0, 0.25);
            cairo.set_source(pat2);
            cairo.move_to(x3, y3);
            cairo.line_to(x3 + x4, y3);
            cairo.curve_to(x3 + x4, y3, x3, y3, x3, y3 + y4);
            cairo.fill();
        }
    }

    /**
     * 次に来るブロックの形状を表示するウィジェット
     */
    public class ReservedDisplayWidget : Gtk.DrawingArea {
        public FallingBlock? blocks { get; set; }
        public Gdk.RGBA bgcolor = { 0.1, 0.1, 0.1, 1.0 };
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
                for (int j = 0; j < blocks.length; j++) {
                    for (int i = 0; i < blocks.length; i++) {
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

    public class ScoreBoard : Gtk.Box {
        public string label {
            get {
                return label_value;
            }
            set {
                label_value = value;
                label_widget.label = label_value;
            }
        }

        public int score {
            get {
                return score_value;
            }
            set {
                score_value = value;
                change_score();
            }
        }

        public int length { get; private set; default = 8; }
        private Gtk.Stack[] stacks;
        private Gtk.Label label_widget;
        private int score_value;
        private string label_value;
        private Pango.AttrList attr_list;

        public ScoreBoard(string label, int length, int initial_score) {
            this.label_value = label;
            this.length = length;
            this.score_value = initial_score;

            attr_list = LabelBuilder.create()
                    .size(12)
                    .weight(BOLD)
                    .attrlist();

            label_widget = new Gtk.Label(label_value) {
                attributes = attr_list
            };

            pack_start(label_widget, false, false);

            stacks = new Gtk.Stack[length];

            for (int i = 0; i < length; i++) {
                stacks[i] = new Gtk.Stack();
                {
                    for (int j = 0; j < 10; j++) {
                        var num_label = new Gtk.Label(j.to_string()) {
                            attributes = attr_list
                        };
                        stacks[i].add_named(num_label, j.to_string());
                    }

                    stacks[i].transition_type = SLIDE_DOWN;
                    stacks[i].visible_child_name = "0";
                }

                pack_end(stacks[i], false, false);
            }

            Idle.add(() => {
                change_score();
                return false;
            });
        }

        private void change_score() {
            string ns = (score_value % 10).to_string();
            if (stacks[0].visible_child_name != ns) {
                stacks[0].visible_child_name = ns;
            }
            for (int i = 1; i < length; i++) {
                int n = score_value;
                n /= (int) Math.pow(10.0, (double) i);
                n %= 10;
                ns = n.to_string();
                if (stacks[i].visible_child_name != ns) {
                    stacks[i].visible_child_name = ns;
                }
            }
        }
    }
}

/**
 * 新規ウィンドウを作成する
 */
Gtk.ApplicationWindow create_window(Gtk.Application app) {
    try {
        // このフラグはゲームが終了したときにダイアログを表示するかどうかの判定に使用する。
        // ブロックが上限に達した場合は表示する。リセットボタン、終了ボタンで終了する
        // 場合にはダイアログを表示しないため、falseにする。
        bool active_flag = true;

        // ゲームモデルの初期化。
        var ahoris_model = new AharoTetris.GameModel(MODEL_10X20);
        AharoTetris.GameWidget ahoris_widget;
        AharoTetris.StopWatch stop_watch;

        // ウィンドウを生成
        var window = new Gtk.ApplicationWindow(app);
        {
            // 以降は普通にウィジェットを組み立てる。

            var headerbar = new Gtk.HeaderBar();
            {
                var title_logo = new Gtk.Image.from_resource("/images/aharo-tetris-logo.png");
                headerbar.custom_title = title_logo;
            }

            var hbox1 = new Gtk.Box(HORIZONTAL, 8);
            {
                ahoris_widget = new AharoTetris.GameWidget.with_model(ahoris_model);
                {
                    ahoris_model.changed.connect(() => {
                        ahoris_widget.queue_draw();
                    });
                }

                var vbox1 = new Gtk.Box(VERTICAL, 8);
                {
                    var hbox2 = new Gtk.Box(HORIZONTAL, 5);
                    {
                        var stop_watch_label = AharoTetris.LabelBuilder.create()
                                .size(12)
                                .weight(BOLD)
                                .label("Time:")
                                .build();

                        stop_watch = new AharoTetris.StopWatch();
                        {
                            stop_watch.halign = END;
                            stop_watch.run.begin();
                        }

                        hbox2.pack_start(stop_watch_label, false, false);
                        hbox2.pack_end(stop_watch, false, false);
                    }

                    var score_board = new AharoTetris.ScoreBoard("Score:", 6, 0);
                    {
                        ahoris_model.score_changed.connect((score, new_score, bonus) => {
                            score_board.score = score;
                        });
                    }

                    var lines_board = new AharoTetris.ScoreBoard("Lines:", 3, 0);
                    {
                        ahoris_model.lines_changed.connect((lines, new_lines) => {
                            lines_board.score = lines;
                        });
                    }

                    var level_board = new AharoTetris.ScoreBoard("Level:", 3, 1);
                    {
                        ahoris_model.level_changed.connect((level) => {
                            level_board.score = level;
                        });
                    }

                    vbox1.pack_start(hbox2, false, false);
                    vbox1.pack_start(score_board, false, false);
                    vbox1.pack_start(lines_board, false, false);
                    vbox1.pack_start(level_board, false, false);
                    vbox1.height_request = ahoris_widget.height_request;
                }

                var vbox2 = new Gtk.Box(VERTICAL, 8);
                {
                    var reserved_display = new AharoTetris.ReservedDisplayWidget(20.0, 20.0, 1.0, 2.0);
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

                    var reset_button = new Gtk.Button.with_label("Reset");
                    {
                        reset_button.clicked.connect(() => {
                            active_flag = false;
                            ahoris_model.force_exit();
                            create_window(app);
                            window.close();
                        });
                    }

                    var exit_button = new Gtk.Button.with_label("Exit");
                    {
                        exit_button.clicked.connect(() => {
                            Process.exit(0);
                        });
                    }

                    var description_grid = new Gtk.Grid();
                    {
                        var image_left = new Gtk.Image();
                        {
                            var pixbuf_left = new Gdk.Pixbuf.from_resource_at_scale("/images/left.svg", 16, 16, true);
                            image_left.pixbuf = pixbuf_left;
                        }

                        var description_left = new Gtk.Label("Move to Left");

                        var image_right = new Gtk.Image();
                        {
                            var pixbuf_right = new Gdk.Pixbuf.from_resource_at_scale("/images/right.svg", 16, 16, true);
                            image_right.pixbuf = pixbuf_right;
                        }

                        var description_right = new Gtk.Label("Move to Right");

                        var image_up = new Gtk.Image();
                        {
                            var pixbuf_up = new Gdk.Pixbuf.from_resource_at_scale("/images/up.svg", 16, 16, true);
                            image_up.pixbuf = pixbuf_up;
                        }

                        var description_up = new Gtk.Label("Turn Left");

                        var image_down = new Gtk.Image();
                        {
                            var pixbuf_down = new Gdk.Pixbuf.from_resource_at_scale("/images/down.svg", 16, 16, true);
                            image_down.pixbuf = pixbuf_down;
                        }

                        var description_down = new Gtk.Label("Turn Right");

                        var label_enter = new Gtk.Label("<b>Enter</b>") { use_markup = true };
                        var description_enter = new Gtk.Label("Drop");

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
                    
                    vbox2.pack_start(reserved_display, false, false);
                    vbox2.pack_start(description_grid, false, false);
                    vbox2.pack_end(exit_button, false, false);
                    vbox2.pack_end(reset_button, false, false);
                    vbox2.height_request = ahoris_widget.height_request;
                }

                hbox1.pack_start(vbox1, false, false);
                hbox1.pack_start(ahoris_widget, false, false);
                hbox1.pack_start(vbox2, false, false);
                hbox1.halign = CENTER;
                hbox1.hexpand = true;
                hbox1.valign = CENTER;
                hbox1.vexpand = true;
                hbox1.margin = 6;
            }

            ahoris_model.game_over.connect(() => {
                if (active_flag) {
                    // ブロックが上限に達して終了した場合はメッセージを表示する。
                    // リセットボタンを押して終了した場合はここを通過しない。
                    active_flag = false;
                    stop_watch.stop();
                    var dialog = new Gtk.MessageDialog(window, MODAL, INFO, OK, "Yes, game over.");
                    dialog.run();
                    dialog.close();
                }
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
                        } catch (AharoTetris.GameError e) {
                            // この例外フローはコーディングミスがあった場合に起きるので
                            // 通常は通らない。
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
    var app = new Gtk.Application("com.github.aharotias2.AharoTetris", FLAGS_NONE);
    app.activate.connect(() => {
        create_window(app);
    });
    return app.run(argv);
}
