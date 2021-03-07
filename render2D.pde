class canvas {
  color [][] grid;
  boolean [][] update;
  int rows, cols;
  float size;
  float res;
  color col = color(255, 255, 255);
  color stroke = color(0, 0, 0);
  color background = color(0, 0, 0);
  boolean edge = true;
  boolean fill = true;
  ArrayList <PVector> changes = new ArrayList <PVector>();

  canvas(float y, float x, float s) {
    rows = floor(x/s);
    cols = floor(y/s);
    size = s;
    res = 1 / s;
    grid = new color[cols][rows];
    update = new boolean[cols][rows];

    for (int i = 0; i < cols; i++)for (int j = 0; j < rows; j++) {
      update[i][j] = true;
      grid[i][j] = 10000;
    }
  }

  void background(float r, float g, float b) {
    background = color(r, g, b);
    for (int i = 0; i < cols; i++)for (int j = 0; j < rows; j++)if (grid[i][j] != background && !update[i][j]) {
      changes.add(new PVector(i, j));
      grid[i][j] = background;
      update[i][j] = true;
    }
  }

  void show() {
    noStroke();
    for (PVector p : changes) {
      fill(grid[round(p.x)][round(p.y)]);
      rect(p.x * size, p.y * size, size, size);
    }
    changes = new ArrayList <PVector>();
    for (int i = 0; i < cols; i++)for (int j = 0; j < rows; j++)update[i][j] = false;
  }

  void circle(float x1, float x2, float r) {
    PVector pos = new PVector(x1, x2);
    float rRes = res * r;
    float aRes = r * (pow(res, -0.03)) * 5;
    if (fill) {
      for (int i = 0; i < rRes; i++) {
        for (float j = 0; j < aRes; j++) {
          PVector p = PVector.fromAngle(TWO_PI * j / aRes).normalize().mult(r);
          p.mult(float(i) / rRes);
          p.add(pos).div(size);
          p.x = round(p.x);
          p.y = round(p.y);
          if (p.x < cols && p.x >= 0 && p.y < rows && p.y >= 0) {
            update[round(p.x)][round(p.y)] = true;
            if (grid[round(p.x)][round(p.y)] != col) {
              changes.add(p.copy());
              grid[round(p.x)][round(p.y)] = col;
            }
          }
        }
      }
    }
    if (edge) {
      for (int i = 0; i < aRes; i++) {
        PVector p = PVector.fromAngle(TWO_PI * i / aRes).normalize().mult(r);
        p.add(pos).div(size);
        p.x = round(p.x);
        p.y = round(p.y);
        if (p.x < cols && p.x >= 0 && p.y < rows && p.y >= 0) {
          update[round(p.x)][round(p.y)] = true;
          if (grid[round(p.x)][round(p.y)] != stroke) {
            changes.add(p.copy());
            grid[round(p.x)][round(p.y)] = stroke;
          }
        }
      }
    }
  }

  void rectangle(float x1, float y1, float w, float h) {
    PVector pos = new PVector(x1 - w / 2, y1 - h / 2);
    PVector line1 = new PVector(w, 0);
    PVector line2 = new PVector(0, h);

    float line1Res = res * line1.mag();
    float line2Res = res * line2.mag();

    if (fill) {
      for (int i = 0; i <= line1Res; i++) {
        PVector p1 = PVector.mult(line1, float(i) / line1Res);
        for (int j = 0; j <= line2Res; j++) {
          PVector p2 = PVector.mult(line2, float(j) / line2Res);
          PVector p = PVector.add(p1, p2).add(pos);
          p.div(size);
          p.x = round(p.x);
          p.y = round(p.y);
          if (p.x < cols && p.x >= 0 && p.y < rows && p.y >= 0) {
            update[round(p.x)][round(p.y)] = true;
            if (grid[round(p.x)][round(p.y)] != col) {
              changes.add(p.copy());
              grid[round(p.x)][round(p.y)] = col;
            }
          }
        }
      }
    }
    if (edge) {
      line(pos.x, pos.y, pos.x + w, pos.y);
      line(pos.x, pos.y, pos.x, pos.y + h);
      line(pos.x + w, pos.y + h, pos.x, pos.y + h);
      line(pos.x + w, pos.y + h, pos.x + w, pos.y);
    }
  }

  void triangle(float x1, float y1, float x2, float y2, float x3, float y3) {
    PVector line1 = new PVector(x2 - x1, y2 - y1);
    PVector line2 = new PVector(x3 - x1, y3 - y1);
    PVector a = new PVector(x1, y1);
    float line1Res = res * line1.mag() * 1.5;
    float line2Res = res * line2.mag() * 1.5;

    if (fill) {
      for (int i = 0; i <= line1Res; i++) {
        PVector p1 = PVector.mult(line1, float(i) / line1Res);
        for (int j = 0; j <= line2Res * (1 - float(i) / line1Res); j++) {
          PVector p2 = PVector.mult(line2, float(j) / line2Res);
          PVector p = PVector.add(p1, p2).add(a);
          p.div(size);
          p.x = round(p.x);
          p.y = round(p.y);
          if (p.x < cols && p.x >= 0 && p.y < rows && p.y >= 0) {
            update[round(p.x)][round(p.y)] = true;
            if (grid[round(p.x)][round(p.y)] != col) {
              changes.add(p.copy());
              grid[round(p.x)][round(p.y)] = col;
            }
          }
        }
      }
    }
    if (edge) {
      line(x1, y1, x2, y2);
      line(x2, y2, x3, y3);
      line(x3, y3, x1, y1);
    }
  }

  void line(float x1, float y1, float x2, float y2) {
    PVector a = new PVector(x1, y1);
    PVector b = new PVector(x2, y2);
    PVector line = PVector.sub(b, a);

    float lineRes = res * line.mag();

    for (int i = 0; i <= lineRes; i++) {
      PVector p = PVector.mult(line, float(i) / lineRes).add(a);
      p.div(size);
      p.x = round(p.x);
      p.y = round(p.y);
      if (p.x < cols && p.x >= 0 && p.y < rows && p.y >= 0) {
        update[round(p.x)][round(p.y)] = true;
        if (grid[round(p.x)][round(p.y)] != stroke) {
          grid[round(p.x)][round(p.y)] = stroke;
          changes.add(p.copy());
        }
      }
    }
  }

  void point(float x, float y) {
    PVector p = new PVector(x, y);
    p.div(size);
    if (p.x < cols && p.x >= 0 && p.y < rows && p.y >= 0) {
      update[round(p.x)][round(p.y)] = true;
      if (grid[round(p.x)][round(p.y)] != col){
        grid[round(p.x)][round(p.y)] = col;
        changes.add(new PVector(round(p.x), round(p.y)));
      }
    }
  }

  void setFill(float r, float g, float b) {
    col = color(r, g, b);
  }

  void setStroke(float r, float g, float b) {
    stroke = color(r, g, b);
  }
}
