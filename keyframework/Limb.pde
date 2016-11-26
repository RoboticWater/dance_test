public class Limb {
  float mag;
  float angle;
  float startAngle;
  color col;
  PVector origin;
  Limb parent;
  JiggleLimb jLimb;
  ArrayList<Limb> children;
  String name;
  public Limb(float _x, float _y, float _mag, float _angle, color _col, String _name) {
    mag    = _mag;
    angle  = _angle;
    startAngle = _angle;
    col    = _col;
    origin = new PVector(_x, _y);
    children = new ArrayList();
    name = _name;
  }
  public Limb(float _mag, float _angle, color _col, String _name, Limb _parent) {
    this(0, 0, _mag, _angle, _col, _name);
    parent = _parent;
    _parent.children.add(this);
  }
  public void draw() {
    pushMatrix();
    if (parent == null) translate(origin.x, origin.y);
    else translate(parent.mag, 0);
    rotate(angle);
    boolean h = (hovered() && focusedLimb == null) || this == focusedLimb;
    if (h) {
      strokeWeight(2);
      stroke(#ff1111);
      ellipse(mag, 0, 20, 20);
      colorMode(HSB);
      stroke(color((map(dRot, 0, 5*TWO_PI, 0, 255) + 90) % 255, 230, 230));
      colorMode(RGB);
      noFill();
      if (dRot >= 0) arc(0, 0, mag * 2, mag * 2, -dRot, 0);
      else arc(0, 0, mag * 2, mag * 2, 0, -dRot);
      if (mousePressed) {
        if (focusedLimb == null) {
          sAngle = angle;
          focusedLimb = this;
        }
        PVector n = new PVector(mouseX - screenX(0, 0, 0), mouseY - screenY(0, 0, 0));
        PVector c = new PVector(screenX(mag, 0, 0) - screenX(0, 0, 0), screenY(mag, 0, 0) - screenY(0, 0, 0));
        if (sign(n.heading()) != sign(pN) && sign(n.heading() - c.heading()) != sign(pdN) && abs(n.heading()) > 0.01) {
          dRot += -TWO_PI * sign(n.heading() - c.heading());
          //println(dRot + n.heading() - c.heading());
        }
        angle += n.heading() - c.heading();
        pN = n.heading();
        pdN = n.heading() - c.heading();
        dRot += pdN;
      } else {
        focusedLimb = null;
      }
    }
    noFill();
    stroke(h ? lerpColor(col, #ffffff, 0.7) : col);
    strokeWeight(6);
    line(0, 0, mag, 0);
    if (children.size() > 0) {
      for (Limb c : children) c.draw();
    }
    if (jLimb != null) 
      jLimb.update(screenX(0, 0, 0), screenY(0, 0, 0), screenX(mag, 0, 0), screenY(mag, 0, 0), realAngle());
    popMatrix();
  }
  private void move() {
  }
  private boolean hovered() {
    return dist(mouseX, mouseY, screenX(mag, 0, 0), screenY(mag, 0, 0)) < 10;
  }
  public PVector[] realPosition() {
    PVector[] out = new PVector[2];
    if (parent == null) {
      out[0] = origin.get();
    } else {
      out[0] = parent.realPosition()[1].get();
    }
    out[1] = new PVector(mag, 0);
    out[1].rotate(realAngle());
    out[1].add(out[0]);
    return out;
  }
  public float realAngle() {
    if (parent == null) return angle;
    return angle + parent.realAngle();
  }
}

int sign(float a) {
  if ((int)Math.signum(a) > -1) return 1;
  else return -1;
}