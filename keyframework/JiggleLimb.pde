import traer.physics.*;

ParticleSystem physics;
float SPRING_STRENGTH = 0.2;
float SPRING_DAMPING = 0.1;
public class JiggleLimb {
  Limb parent;
  Particle tOrg, tExt;
  Particle org, ext;
  Particle bOrg, bExt;
  Particle[][] particles;
  JiggleLimb next, prev;
  float angle;
  float oSize;
  float eSize;
  public JiggleLimb(Limb _parent, JiggleLimb _jParent, float _oSize, float _eSize, int _num) {
    parent = _parent;
    prev = _jParent;
    parent.jLimb = this;
    oSize = _oSize;
    eSize = _eSize;
    angle = parent.realAngle();
    //println(angle);
    particles = new Particle[_num][3];
    if (prev == null) meshNoPrev(_num);
    else meshPrev(_num);
  }
  public void draw() {
    //for (int x = 0; x < particles.length; x++) {
    //  for (int y = 0; y < particles[0].length; y++) {
    //    point(particles[x][y].position().x(), particles[x][y].position().y());
    //  }
    //}
    fill(0);
    stroke(0);
    beginShape();
    curveVertex(particles[0][0].position().x(), particles[0][0].position().y());
    for (int i = 0; i < particles.length - 1; i++) {
      curveVertex(particles[i][0].position().x(), particles[i][0].position().y());
    }
    curveVertex(particles[particles.length - 1][0].position().x(), particles[particles.length - 1][0].position().y());
    curveVertex(particles[particles.length - 1][0].position().x(), particles[particles.length - 1][0].position().y());
    vertex(particles[particles.length - 1][2].position().x(), particles[particles.length - 1][2].position().y());
    for (int i = particles.length - 1; i >= 0; i--) {
      curveVertex(particles[i][2].position().x(), particles[i][2].position().y());
    }
    curveVertex(particles[0][2].position().x(), particles[0][2].position().y());
    endShape();
    //arc(org.position().x(), org.position().y(), oSize, oSize, angle + HALF_PI, angle + HALF_PI + PI);
    //arc(ext.position().x(), ext.position().y(), eSize, eSize, angle + HALF_PI + PI, angle + HALF_PI + TWO_PI);
  }
  public void update(float ox, float oy, float ex, float ey, float a) {
    angle = a;
    org.position().set(ox, oy, 0);
    org.velocity().clear();
    ext.position().set(ex, ey, 0);
    ext.velocity().clear();
    
    PVector start = new PVector(oSize / 2, 0);
    start.rotate(angle + HALF_PI);
    start.add(new PVector(ox, oy));
    PVector end = new PVector(eSize / 2, 0);
    end.rotate(angle + HALF_PI);
    end.add(new PVector(ex, ey));
    tOrg.position().set(start.x, start.y, 0);
    tExt.position().set(end.x, end.y, 0);
    tOrg.velocity().clear();
    tExt.velocity().clear();
    
    start.set(oSize / 2, 0);
    start.rotate(angle + PI + HALF_PI);
    start.add(new PVector(ox, oy));
    end.set(eSize / 2, 0);
    end.rotate(angle + PI + HALF_PI);
    end.add(new PVector(ex, ey));
    bOrg.position().set(start.x, start.y, 0);
    bExt.position().set(end.x, end.y, 0);
    bOrg.velocity().clear();
    bExt.velocity().clear();
  }
  private void meshNoPrev(int _num) {
    PVector[] p = parent.realPosition();
    PVector start = new PVector(oSize / 2, 0);
    start.rotate(angle + HALF_PI);
    start.add(p[0]);
    PVector end = new PVector(eSize / 2, 0);
    end.rotate(angle + HALF_PI);
    end.add(p[1]);
    //Middle
    for (int x = 0; x < _num; x++) {
      float vx = map(x, 0, _num - 1, p[0].x, p[1].x);
      float vy = map(x, 0, _num - 1, p[0].y, p[1].y);
      particles[x][1] = physics.makeParticle(0.2, vx, vy, 0);
      if (x == 0 || x == _num - 1) particles[x][1].makeFixed();
      if (x > 0) {
        float d = particles[x - 1][1].position().distanceTo(particles[x][1].position());
        physics.makeSpring(particles[x - 1][1], particles[x][1], SPRING_STRENGTH, SPRING_DAMPING, d);
      }
    }
    //Top
    for (int x = 0; x < _num; x++) {
      float vx = map(x, 0, _num - 1, start.x, end.x);
      float vy = map(x, 0, _num - 1, start.y, end.y);
      particles[x][0] = physics.makeParticle(0.2, vx, vy, 0);
      if (x == 0 || x == _num - 1) particles[x][0].makeFixed();
      if (x > 0) {
        float d = particles[x - 1][0].position().distanceTo(particles[x][0].position());
        physics.makeSpring(particles[x - 1][0], particles[x][0], SPRING_STRENGTH, SPRING_DAMPING, d * 0.9);
      }
    }
    start.set(oSize / 2, 0);
    start.rotate(angle + PI + HALF_PI);
    start.add(p[0]);
    end.set(eSize / 2, 0);
    end.rotate(angle + PI + HALF_PI);
    end.add(p[1]);
    //Bottom
    for (int x = 0; x < _num; x++) {
      float vx = map(x, 0, _num - 1, start.x, end.x);
      float vy = map(x, 0, _num - 1, start.y, end.y);
      particles[x][2] = physics.makeParticle(0.2, vx, vy, 0);
      if (x == 0 || x == _num - 1) particles[x][2].makeFixed();
      if (x > 0) {
        float d = particles[x - 1][2].position().distanceTo(particles[x][2].position());
        physics.makeSpring(particles[x - 1][2], particles[x][2], SPRING_STRENGTH, SPRING_DAMPING, d * 0.9);
      }
    }

    for (int y = 0; y < 3; y++) {
      for (int x = 1; x < _num; x++) {
        float d = particles[x - 1][y].position().distanceTo(particles[x][y].position());
        physics.makeSpring(particles[x - 1][y], particles[x][y], SPRING_STRENGTH, SPRING_DAMPING, d * 0.9);
      }
    }
    tOrg = particles[0][0];
    tExt = particles[_num - 1][0];
    org = particles[0][1];
    ext = particles[_num - 1][1];
    bOrg = particles[0][2];
    bExt = particles[_num - 1][2];
  }
  private void meshPrev(int _num) {
    PVector[] p = parent.realPosition();
    PVector start = new PVector(oSize / 2, 0);
    start.rotate(angle + HALF_PI);
    start.add(p[0]);
    PVector end = new PVector(eSize / 2, 0);
    end.rotate(angle + HALF_PI);
    end.add(p[1]);
    particles[0][0] = prev.particles[prev.particles.length - 1][0];
    particles[0][1] = prev.particles[prev.particles.length - 1][1];
    particles[0][2] = prev.particles[prev.particles.length - 1][2];
    //Middle
    for (int x = 0; x < _num; x++) {
      float vx = map(x, 0, _num - 1, p[0].x, p[1].x);
      float vy = map(x, 0, _num - 1, p[0].y, p[1].y);
      if (x != 0) particles[x][1] = physics.makeParticle(0.2, vx, vy, 0);
      if (x == 0 || x == _num - 1) particles[x][1].makeFixed();
      if (x > 0) {
        float d = particles[x - 1][1].position().distanceTo(particles[x][1].position());
        physics.makeSpring(particles[x - 1][1], particles[x][1], SPRING_STRENGTH, SPRING_DAMPING, d);
      }
    }
    //Top
    for (int x = 0; x < _num; x++) {
      float vx = map(x, 0, _num - 1, start.x, end.x);
      float vy = map(x, 0, _num - 1, start.y, end.y);
      if (x != 0) particles[x][0] = physics.makeParticle(0.2, vx, vy, 0);
      if (x == 0 || x == _num - 1) particles[x][0].makeFixed();
      if (x > 0) {
        float d = particles[x - 1][0].position().distanceTo(particles[x][0].position());
        physics.makeSpring(particles[x - 1][0], particles[x][0], SPRING_STRENGTH, SPRING_DAMPING, d * 0.9);
      }
    }
    start.set(oSize / 2, 0);
    start.rotate(angle + PI + HALF_PI);
    start.add(p[0]);
    end.set(eSize / 2, 0);
    end.rotate(angle + PI + HALF_PI);
    end.add(p[1]);
    //Bottom
    for (int x = 0; x < _num; x++) {
      float vx = map(x, 0, _num - 1, start.x, end.x);
      float vy = map(x, 0, _num - 1, start.y, end.y);
      if (x != 0) particles[x][2] = physics.makeParticle(0.2, vx, vy, 0);
      if (x == 0 || x == _num - 1) particles[x][2].makeFixed();
      if (x > 0) {
        float d = particles[x - 1][2].position().distanceTo(particles[x][2].position());
        physics.makeSpring(particles[x - 1][2], particles[x][2], SPRING_STRENGTH, SPRING_DAMPING, d * 0.9);
      }
    }

    for (int y = 0; y < 3; y++) {
      for (int x = 1; x < _num; x++) {
        float d = particles[x - 1][y].position().distanceTo(particles[x][y].position());
        physics.makeSpring(particles[x - 1][y], particles[x][y], SPRING_STRENGTH, SPRING_DAMPING, d * 0.9);
      }
    }
    
    tOrg = particles[0][0];
    tOrg.makeFree();
    tExt = particles[_num - 1][0];
    org = particles[0][1];
    org.makeFree();
    ext = particles[_num - 1][1];
    bOrg = particles[0][2];
    bOrg.makeFree();
    bExt = particles[_num - 1][2];
  }
}