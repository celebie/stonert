// copy pastes pattern... 
// i mean, i hate processing.

class Sand {
  float swt = 25.0;     //sep.mult(25.0f);
  float awt = 1.0;      //ali.mult(4.0f);
  float cwt = 2.0;      //coh.mult(5.0f);
  float maxspeed = 5;
  float maxforce = 0.015;
  float zR = 10;
  float collisionWeaken = 0.8;

  SandBody body;

  float r = 500;

  Vec3D loc = new Vec3D(0, 0, 0);
  Vec3D vel = new Vec3D(0, 0, 0);
  Vec3D acc = new Vec3D(0, 0, 0);
  Boolean isAlive = true;
  Boolean speedLimit = true;

  Sand(float x, float y, float z) {
    body = new SandBody();
    acc = new Vec3D(0, 0, 0);
    vel = new Vec3D(random(0.5,1), random(-1,1), random(-30,30));
    loc = new Vec3D(x, y, z);
  }

  void run(CopyOnWriteArrayList<Sand> sands) {
    flock(sands);
    update();
    borders();
    render();
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(CopyOnWriteArrayList<Sand> sands) {
    Vec3D sep = separate(sands);   // Separation
    Vec3D ali = align(sands);      // Alignment
    Vec3D coh = cohesion(sands);   // Cohesion

    // Arbitrarily weight these forces
    sep.scaleSelf(swt);
    ali.scaleSelf(awt);
    coh.scaleSelf(cwt);

    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  void update() {
    // Update velocity
    vel.addSelf(acc);
    // Limit speed
    if (speedLimit) {
      vel.limit(maxspeed);
    }

    loc.addSelf(vel);
    // Reset accelertion to 0 each cycle
    acc.scaleSelf(0);

    body.update();
  }

  void borders() {
    if (loc.x < -r || loc.x > width+r
        || loc.y < -r || loc.y > height+r) {
      isAlive = false;
    }

    if (loc.z > zR) {
      vel.z = -abs(vel.z) * collisionWeaken;
    }

    if (loc.z < -zR) {
      vel.z = abs(vel.z) * collisionWeaken;
    }
  }

  void render() {
    pushMatrix();

    translate(loc.x, loc.y, loc.z);
    body.render();

    popMatrix();
  }

  void applyForce(Vec3D force) {
    // We could add mass here if we want A = F / M
    acc.addSelf(force);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  Vec3D seek(Vec3D target) {
    Vec3D desired = target.sub(loc);  // A vector pointing from the location to the target

    // Normalize desired and scale to maximum speed
    desired.normalizeTo(maxspeed);
    // Steering = Desired minus Velocity
    Vec3D steer = desired.sub(vel);
    steer.limit(maxforce);  // Limit to maximum steering force

    return steer;
  }

  // Separation
  // Method checks for nearby sands and steers away
  Vec3D separate (CopyOnWriteArrayList<Sand> sands) {
    float desiredseparation = 25.0;
    Vec3D steer = new Vec3D(0, 0, 0);
    int count = 0;
    // For every sand in the system, check if it's too close
    for (Sand other : sands) {
      float d = loc.distanceTo(other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        Vec3D diff = loc.sub(other.loc);
        diff.normalizeTo(1.0/d);
        steer.addSelf(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.scaleSelf(1.0/(float)count);
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalizeTo(maxspeed);
      steer.subSelf(vel);
      steer.limit(maxforce);
    }
    return steer;
  }


  // Alignment
  // For every nearby sand in the system, calculate the average velocity
  Vec3D align (CopyOnWriteArrayList<Sand> sands) {
    float neighbordist = 50.0;
    Vec3D steer = new Vec3D();
    int count = 0;
    for (Sand other : sands) {
      float d = loc.distanceTo(other.loc);

      if ((d > 0) && (d < neighbordist)) {
        steer.addSelf(other.vel);
        count++;
      }
    }
    if (count > 0) {
      steer.scaleSelf(1.0/(float)count);
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalizeTo(maxspeed);
      steer.subSelf(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby sands, calculate steering vector towards that location
  Vec3D cohesion (CopyOnWriteArrayList<Sand> sands) {
    float neighbordist = 50.0;
    Vec3D sum = new Vec3D(0, 0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Sand other : sands) {
      float d = loc.distanceTo(other.loc);

      if ((d > 0) && (d < neighbordist)) {
        sum.addSelf(other.loc); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.scaleSelf(1.0/(float)count);
      return seek(sum);  // Steer towards the location
    }
    return sum;
  }
}
