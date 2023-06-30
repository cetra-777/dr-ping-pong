def defaults(args)
  args.state.winning_number ||= 2
  args.state.score ||= 0
  args.state.comp_score ||= 0
  args.state.playing ||= true
  args.state.game_won ||= false
  args.state.game_lost ||= false
  args.state.bg ||= { x: 0, y: 0, w: args.grid.w, h: args.grid.h, r: 56, g: 23, b: 30 }
  args.state.center_bar ||= { x: args.grid.w / 2 - 5, y: 0, w: 10, h: args.grid.h, r: 57, g: 209, b: 239 }
  args.state.l_score = { x: args.grid.w / 4, y: args.grid.h * 0.9, text: args.state.score, size_enum: 20,
                         font: 'Adventurer.ttf', r: 57, g: 209, b: 239 }
  args.state.r_score = { x: args.grid.w * 0.75, y: args.grid.h * 0.9, text: args.state.comp_score, size_enum: 20,
                         font: 'Adventurer.ttf', r: 57, g: 209, b: 239 }

  args.state.l_paddle ||= { x: args.grid.w * 0.05 - 10, y: args.grid.h / 2 - 75, w: 20, h: 150, r: 53, g: 209, b: 48,
                            speed: 10 }
  args.state.r_paddle ||= { x: args.grid.w * 0.95 - 10, y: args.grid.h / 2 - 75, w: 20, h: 150, r: 234, g: 181, b: 65,
                            speed: 7 }
  args.state.ball ||= { x: args.grid.w / 2 - 15, y: args.grid.h / 2 - 15, w: 30, h: 30, r: 16, g: 80, b: 229,
                        x_accel: -7, y_accel: -7 }

  args.state.solids ||= [args.state.bg, args.state.center_bar, args.state.l_paddle, args.state.r_paddle,
                         args.state.ball]
end

def input(args)
  return if args.inputs.up && args.inputs.down

  if args.inputs.up
    args.state.l_paddle.y += args.state.l_paddle.speed
    if args.state.l_paddle.y >= args.grid.h - args.state.l_paddle.h
      args.state.l_paddle.y = args.grid.h - args.state.l_paddle.h
    end
  elsif args.inputs.down
    args.state.l_paddle.y -= args.state.l_paddle.speed
    args.state.l_paddle.y = 0 if args.state.l_paddle.y <= 0
  end
end

def game_over(args)
  return unless args.state.comp_score >= args.state.winning_number || args.state.score >= args.state.winning_number

  args.state.playing = false

  if args.state.comp_score >= args.state.winning_number
    args.outputs.labels << [{ x: args.grid.w * 0.5, y: args.grid.h * 0.75, text: 'Game Over', size_enum: 50, alignment_enum: 1,
                              font: 'Adventurer.ttf', r: 255, g: 255, b: 255 }]
  elsif args.state.score >= args.state.winning_number

    args.outputs.labels << [{ x: args.grid.w * 0.5, y: args.grid.h * 0.75, text: 'Congratulations!', size_enum: 50, alignment_enum: 1,
                              font: 'Adventurer.ttf', r: 255, g: 255, b: 255 }]
  end
  args.outputs.labels << [{ x: args.grid.w * 0.5, y: args.grid.h * 0.4, text: 'Press R to play again', size_enum: 30, alignment_enum: 1,
                            font: 'Adventurer.ttf', r: 255, g: 255, b: 255 }]
  return unless args.inputs.keyboard.key_down.r

  args.gtk.reset_next_tick
end

def player_score(args)
  args.state.score += 1
  args.state.ball.x = args.grid.w / 2 - 15
  args.state.ball.y = args.grid.h / 2 - 15
  args.state.ball.x_accel = - 7
  args.state.ball.y_accel = 0

  return unless args.state.score >= args.state.winning_number

  args.state.game_won = true
end

def computer_score(args)
  args.state.comp_score += 1
  args.state.ball.x = args.grid.w / 2 - 15
  args.state.ball.y = args.grid.h / 2 - 15
  args.state.ball.x_accel = 7
  args.state.ball.y_accel = 0

  return unless args.state.comp_score >= args.state.winning_number

  args.state.game_lost = true
end

def reflect_ball_left(args)
  return unless args.geometry.intersect_rect?(args.state.ball, args.state.l_paddle)

  player_paddle_center = args.state.l_paddle.y + args.state.l_paddle.h / 2
  y_accel = args.state.ball.y_accel

  args.state.ball.x_accel *= -1
  if player_paddle_center < args.grid.h / 2 && y_accel >= 0
    args.state.ball.y_accel += 2
  elsif player_paddle_center < args.grid.h / 2 && y_accel <= 0
    args.state.ball.y_accel = args.state.ball.y_accel * -1 + 2
  elsif player_paddle_center >= args.grid.h / 2 && y_accel <= 0
    args.state.ball.y_accel -= 2
  elsif player_paddle_center >= args.grid.h / 2 && y_accel >= 0
    args.state.ball.y_accel = args.state.ball.y_accel * -1 + 2
  end
end

def reflect_ball_right(args)
  return unless args.geometry.intersect_rect?(args.state.ball, args.state.r_paddle)

  computer_paddle_center = args.state.r_paddle.y + args.state.r_paddle.h / 2
  y_accel = args.state.ball.y_accel

  args.state.ball.x_accel *= -1
  if computer_paddle_center < args.grid.h / 2 && y_accel >= 0
    args.state.ball.y_accel += 2
  elsif computer_paddle_center < args.grid.h / 2 && y_accel <= 0
    args.state.ball.y_accel = args.state.ball.y_accel * -1 + 2
  elsif computer_paddle_center >= args.grid.h / 2 && y_accel <= 0
    args.state.ball.y_accel -= 2
  elsif computer_paddle_center >= args.grid.h / 2 && y_accel >= 0
    args.state.ball.y_accel = args.state.ball.y_accel * -1 + 2
  end
end

def ai_movement(args)
  if args.state.ball.y > args.state.r_paddle.y
    args.state.r_paddle.y += args.state.r_paddle.speed
  elsif args.state.ball.y < args.state.r_paddle.y
    args.state.r_paddle.y -= args.state.r_paddle.speed
  else
    args.state.r_paddle.y += 0
  end
  if args.state.r_paddle.y + args.state.r_paddle.h >= args.grid.h
    args.state.r_paddle.y = args.grid.h - args.state.r_paddle.h
  end
  return unless args.state.r_paddle.y <= 0

  args.state.r_paddle.y = 0
end

def ball_movement(args)
  reflect_ball_left args
  reflect_ball_right args
  args.state.ball.x += args.state.ball.x_accel
  args.state.ball.y += args.state.ball.y_accel

  if args.state.ball.y >= args.grid.h - args.state.ball.h or args.state.ball.y <= 0
    args.state.ball.y_accel *= -1
  elsif args.state.ball.x <= 0
    computer_score args
  elsif args.state.ball.x >= args.grid.w - args.state.ball.w
    player_score args
  end
end

def render(args)
  args.outputs.solids << args.state.solids
  args.outputs.labels << [args.state.l_score, args.state.r_score]
end

def tick(args)
  defaults args
  render args
  game_over args
  return unless args.state.playing == true

  input args
  ball_movement args
  ai_movement args
end

$gtk.reset
