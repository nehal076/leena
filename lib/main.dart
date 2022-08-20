import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:leena/actors/leena.dart';
import 'package:leena/world/ground.dart';
import 'package:tiled/tiled.dart';

void main() {
  runApp(GameWidget(game: LeenaGame()));
}

class LeenaGame extends FlameGame with HasCollisionDetection, TapDetector {
  Leena leena = Leena();
  final double gravity = 2.5;
  final double pushSpeed = 100;
  final double jumpForce = 130;

  Vector2 velocity = Vector2(0, 0);
  late TiledComponent homeMap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // add(SpriteComponent()
    //   ..sprite = await loadSprite('background.png')
    //   ..size = size);

    homeMap = await TiledComponent.load('map.tmx', Vector2.all(32));
    add(homeMap);

    double mapWidth = 32.0 * homeMap.tileMap.map.width;
    double mapHeight = 32.0 * homeMap.tileMap.map.height;

    final obstacleGroup = homeMap.tileMap.getLayer<ObjectGroup>('ground');

    for (final obj in obstacleGroup!.objects) {
      add(
        Ground(
          size: Vector2(obj.width, obj.height),
          position: Vector2(obj.x, obj.y),
        ),
      );
    }

    camera.viewport = FixedResolutionViewport(Vector2(mapWidth, mapHeight));

    leena
      ..sprite = await loadSprite('girl.png')
      ..size = Vector2(80, 100)
      ..position = Vector2(350, 90);

    add(leena);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!leena.onGround) {
      velocity.y += gravity;
    }
    leena.position += velocity * dt;
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    if (leena.onGround) {
      if (info.eventPosition.game.x < 100) {
        print('move left');
        if (leena.facingRight) {
          leena.facingRight = false;
          leena.flipHorizontallyAroundCenter();
        }
        leena.x -= 5;
        velocity.x -= pushSpeed;
      } else if (info.eventPosition.game.x > size[0] - 100) {
        print('move right');
        if (!leena.facingRight) {
          leena.facingRight = true;
          leena.flipHorizontallyAroundCenter();
        }
        leena.x += 5;
        velocity.x += pushSpeed;
      }

      if (info.eventPosition.game.y < 100) {
        print('jump');
        leena.y -= 10;
        velocity.y = -jumpForce;
      }
    }
  }
}
