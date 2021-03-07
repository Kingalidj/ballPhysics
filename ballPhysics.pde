ArrayList <ball> balls = new ArrayList <ball>();
ArrayList <line> lines = new ArrayList <line>();

ball selectedBall = null;
line selectedLine = null;
canvas c;

float defaultRadius = 40;
int nBalls = 200;
int nLines = 3;
int time;
int nSimulationUpdates = 3;
int maxSimSteps = 10;
boolean selectedLineStart = false;

void setup() {
	size(1800, 1200);	
	c = new canvas(width, height, 5);

	for (int i = 0; i < nBalls; i++)
		balls.add(new ball(random(width), random(height), random(10, 20)));

	float segment = height / (nLines + 1);
	for (int i = 0; i < nLines; i++)
		lines.add(new line(100, (i + 1) * segment, 900, (i + 1) * segment, 20));
}

void draw() {
	for (ball b : balls)
		b.show();
	for (line l : lines)
		l.show();

	update();

	c.background(0, 0, 0);
	c.show();
	time = millis();
}

void update() {
	ArrayList <ball[]> collidingPairs = new ArrayList <ball[]>();
	ArrayList <ball> fakeBalls = new ArrayList <ball>();

	float elapsedTime = millis() - time;
	float simElapsedTime = elapsedTime / nSimulationUpdates;

	if (selectedBall != null && mouseButton == RIGHT) {
		c.setStroke(0, 0, 200);
		c.line(mouseX, mouseY, selectedBall.pos.x, selectedBall.pos.y);
	}

	for (int i = 0; i < nSimulationUpdates; i++) {

		for (ball b : balls)b.simTimeRemaining = simElapsedTime;

		for (int j = 0; j < maxSimSteps; j++) {
			for (ball b : balls) {
				if (b.simTimeRemaining > 0) {
					b.old = b.pos.copy();
					b.acc = (b.vel.copy().mult(-0.01));
					b.acc.y += 0.1;
					b.vel.add(b.acc.copy().mult(b.simTimeRemaining / (nSimulationUpdates * maxSimSteps + 9)));
					b.pos.add(b.vel.copy().mult(b.simTimeRemaining / (nSimulationUpdates * maxSimSteps + 9)));

					if (b.pos.x < 0)b.pos.x += width;
					if (b.pos.x >= width)b.pos.x -= width;
					if (b.pos.y < 0)b.pos.y += height;
					if (b.pos.y >= height)b.pos.y -= height;

					if (b.vel.mag() < 0.01)b.vel = new PVector(0, 0);
				}
			}

			//static collision
			for (ball b : balls) {
				for (line l : lines) {
					PVector l1 = l.e.copy().sub(l.s);
					PVector l2 = b.pos.copy().sub(l.s);
					float length = l1.x * l1.x + l1.y * l1.y;
					float t = max(0, min(length, l1.copy().dot(l2))) / length;
					PVector closest = l.s.copy().add(l1.mult(t));
					float distance = dist(b.pos.x, b.pos.y, closest.x, closest.y);

					if (distance <= (b.radius + l.radius)) {
						ball fakeBall = new ball(closest.x, closest.y, l.radius);
						fakeBall.mass = b.mass;
						fakeBall.vel = b.vel.copy().mult(-1);
						ball [] pairs = {fakeBall, b};

						//fakeBalls.add(fakeBall);
						collidingPairs.add(pairs);

						float overlap = distance - b.radius - fakeBall.radius;
						b.pos.x -= overlap * (b.pos.x - fakeBall.pos.x) / distance;
						b.pos.y -= overlap * (b.pos.y - fakeBall.pos.y) / distance;
					}
				}
				for (ball target : balls) {
					if (b.id != target.id) {
						if (doOverlap(b.pos, b.radius, target.pos, target.radius)) {
							ball [] pairs = {b, target};
							collidingPairs.add(pairs);

							float dist = dist(b.pos.x, b.pos.y, target.pos.x, target.pos.y);
							float overlap = (dist- b.radius - target.radius) / 2;

							b.pos.x -= overlap * (b.pos.x - target.pos.x) / dist;
							b.pos.y -= overlap * (b.pos.y - target.pos.y) / dist;

							target.pos.x += overlap * (b.pos.x - target.pos.x) / dist;
							target.pos.y += overlap * (b.pos.y - target.pos.y) / dist;
						}
					}
				}
				
				//time displacement
				float intendedSpeed = b.vel.mag();
				float intendedDistance = intendedSpeed * b.simTimeRemaining;
				float actualDistance = b.pos.copy().sub(b.old).mag();
				float actualTime = actualDistance / intendedSpeed;

			}

			//dynamic collision
			for (ball [] pairs : collidingPairs) {
				ball b1 = pairs[0];
				ball b2 = pairs[1];

				float distance = dist(b1.pos.x, b1.pos.y, b2.pos.x, b2.pos.y);
				PVector normal = b2.pos.copy().sub(b1.pos).div(distance);
				PVector tangent = new PVector(-normal.y, normal.x);

				float dpTan1 = b1.vel.copy().dot(tangent);
				float dpTan2 = b2.vel.copy().dot(tangent);

				float dpNorm1 = b1.vel.copy().dot(normal);
				float dpNorm2 = b2.vel.copy().dot(normal);

				float m1 = (dpNorm1 * (b1.mass - b2.mass) + 2 * b2.mass * dpNorm2) / (b1.mass + b2.mass);
				float m2 = (dpNorm2 * (b2.mass - b1.mass) + 2 * b1.mass * dpNorm1) / (b1.mass + b2.mass);

				b1.vel = tangent.copy().mult(dpTan1).add(normal.copy().mult(m1));
				b2.vel = tangent.copy().mult(dpTan2).add(normal.copy().mult(m2));


				//c.setStroke(200, 0, 0);
				//c.line(b1.pos.x, b1.pos.y, b2.pos.x, b2.pos.y);
			}
			fakeBalls = new ArrayList <ball>();
			collidingPairs = new ArrayList <ball[]>();
		}
	}
}

void mousePressed() {
	selectedBall = null;
	selectedLine = null;
	for (ball b : balls) {
		if (isInCircle(b.pos, b.radius, mouseX, mouseY)) {
			selectedBall = b;
			selectedBall.vel = new PVector(0, 0);
			selectedBall.acc = new PVector(0, 0);
			break;
		}
	}
	if (selectedBall == null)
		for (line l : lines) {
			if (isInCircle(l.s, l.radius, mouseX, mouseY)) {
				selectedLine = l;
				selectedLineStart = true;
				break;
			}
			if (isInCircle(l.e, l.radius, mouseX, mouseY)) {
				selectedLine = l;
				selectedLineStart = false;
				break;
			}
		}
}

void mouseDragged() {
	if (selectedBall != null && mouseButton == LEFT)selectedBall.pos = new PVector(mouseX, mouseY);
	if (selectedLine != null)
		if (selectedLineStart)selectedLine.s = new PVector(mouseX, mouseY);
		else selectedLine.e = new PVector(mouseX, mouseY);
}

void mouseReleased() {
	if (mouseButton == LEFT) {
		selectedBall = null;
		selectedLine = null;
	}
	else if (selectedBall != null) {
		selectedBall.vel = selectedBall.pos.copy().sub(new PVector(mouseX, mouseY)).div(20);
		selectedBall = null;
	}
}

boolean doOverlap (PVector pos1, float r1, PVector pos2, float r2) {
	return (dist(pos1.x, pos1.y, pos2.x, pos2.y) <= r1 + r2);
}

boolean isInCircle (PVector pos, float r, float x, float y) {
	return (dist(pos.x, pos.y, x, y) < r);
}

class line {
	PVector s, e;
	float radius;

	line(float x, float y, float u, float v, float r) {
		s = new PVector(x, y);
		e = new PVector(u, v);
		radius = r;

	}

	void show() {
		c.edge = false;
		c.fill = true;
		c.setFill(255, 255, 255);
		c.circle(s.x, s.y, radius);
		c.circle(e.x, e.y, radius);

		PVector n = new PVector(s.y - e.y, e.x - s.x).normalize().mult(radius);
		c.setStroke(255, 255, 255);
		c.line(s.x + n.x, s.y + n.y, e.x + n.x, e.y + n.y);
		c.line(s.x - n.x, s.y - n.y, e.x - n.x, e.y - n.y);
		
	}

}

class ball {
	PVector pos, old, vel, acc;
	float radius;
	float mass;
	float simTimeRemaining;
	int id;

	ball(float x, float y, float r) {
		pos = new PVector(x, y);
		vel = new PVector(0, 0);
		acc = new PVector(0, 0);
		radius = r;
		mass = r * 10;
		id = balls.size();
	}

	void show() {
		if (selectedBall != null)
			if (selectedBall.id == this.id && mouseButton == LEFT) {
				pos = new PVector(mouseX, mouseY);
			}
		c.edge = false;
		c.fill = true;
		c.setFill(200, 0, 0);
		c.circle(pos.x, pos.y, radius);
	}
}
