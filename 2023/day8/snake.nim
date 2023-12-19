import sdl, sdl.mixer, sdl.ttf, sdl.gfx

const
  SCREEN_WIDTH = 640
  SCREEN_HEIGHT = 480
  BLOCK_SIZE = 10
  SNAKE_SPEED = 100

type
  Point = tuple[x, y: int]
  Snake = seq[Point]

var
  window: ptr SDL_Window
  renderer: ptr SDL_Renderer
  snake: Snake
  food: Point
  running = true
  direction = SDLK_RIGHT

proc init() =
  SDL_Init(SDL_INIT_VIDEO)
  window = SDL_CreateWindow("Snake Game", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN)
  renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED)

proc close() =
  SDL_DestroyRenderer(renderer)
  SDL_DestroyWindow(window)
  SDL_Quit()

proc drawSnake(snake: Snake) =
  for p in snake:
    SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255)
    SDL_Rect rect = (p.x * BLOCK_SIZE, p.y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
    SDL_RenderFillRect(renderer, @rect)

proc drawFood(food: Point) =
  SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255)
  SDL_Rect rect = (food.x * BLOCK_SIZE, food.y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
  SDL_RenderFillRect(renderer, @rect)

proc generateFood() =
  var x, y = rand(SCREEN_WIDTH / BLOCK_SIZE), rand(SCREEN_HEIGHT / BLOCK_SIZE)
  while (x, y) in snake:
    x, y = rand(SCREEN_WIDTH / BLOCK_SIZE), rand(SCREEN_HEIGHT / BLOCK_SIZE)
  food = (x, y)

proc moveSnake() =
  var newHead = snake[0]
  case direction
  of
    SDLK_UP: newHead.y -= 1
    SDLK_DOWN: newHead.y += 1
    SDLK_LEFT: newHead.x -= 1
    SDLK_RIGHT: newHead.x += 1

  snake.insert(0, newHead)

  if newHead = food:
    generateFood()
  else:
    snake.pop()

proc handleInput() =
  var event: SDL_Event
  while SDL_PollEvent(@event)!= 0:
    case event.type
    of
      SDL_QUIT: running = false
      SDL_KEYDOWN:
        if event.key.keysym.sym in [SDLK_UP, SDLK_DOWN, SDLK_LEFT, SDLK_RIGHT]:
          direction = event.key.keysym.sym

proc main() =
  init()
  snake = @[(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)]
  generateFood()

  while running:
    handleInput()
    moveSnake()

    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
    SDL_RenderClear(renderer)

    drawSnake(snake)
    drawFood(food)

    SDL_RenderPresent(renderer)

    SDL_Delay(SNAKE_SPEED)

  close()

main()