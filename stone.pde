float sizeWeight = 50;

class Stone {
  ArrayList<Vec3D> vecs;
  ArrayList<Face> faces = new ArrayList<Face>();

  Vec3D jitterSize = new Vec3D(3, 3, 3);
  Boolean jitterOn = false;
  Boolean sizeJitterOn = true;

  float size = 100;
  float origSize = size;
  float minSize = 10;
  float maxSize = 250;
  Boolean selfRotate = false;
  Vec3D angVel = Vec3D.randomVector().normalizeTo(radians(0.3));
  Vec3D test1;
  Vec3D test2;

  int freq = 0;
  float freqAmp = 0;

  color ccolor = white;
  color normalColor = ccolor;
  color changingColor;

  Stone(ArrayList<Vec3D> _vecs) {
    vecs = _vecs;
    initialize();
  }

  Stone() {
    initToTetrahedra();
    initialize();
  }

  Stone(float size) {
    size = size;
    origSize = size;

    initToTetrahedra();
    initialize();
  }

  void initToTetrahedra() {
    Vec3D a = new Vec3D(1, 0, 0);
    Vec3D b = new Vec3D(1, 0, 0);
    Vec3D c = new Vec3D(1, 0, 0);
    Vec3D d = new Vec3D(1, 0, 0);

    b.rotateZ(radians(120));

    c.rotateZ(radians(120));
    c.rotateX(radians(120));

    d.rotateZ(radians(120));
    d.rotateX(-radians(120));

    vecs = new ArrayList<Vec3D>();
    vecs.add(a);
    vecs.add(b);
    vecs.add(c);
    vecs.add(d);
  }

  // fucking processing stupid `this` keyword.
  void initialize() {
    scale(size);

    changingColor = getColor();
    addFaces(vecs);
    shapeJitter();
  }

  void update() {
    if (jitterOn) {
      shapeJitter();
      limitShape();
    }
    if (sizeJitterOn) {
      sizeJitter();
    }
    for(Face f: faces) {
      f.setColor(ccolor);
      f.update();
    }
    if (selfRotate) {
      rotate3D(angVel);
    }
    limitShape();
  }

  void render() {
    if (debug) {
      stroke(gray);
      lineV(getPointVec().scaleSelf(size));
      stroke(disco);
      lineV(test1);
      stroke(black);
      lineV(test2);
      return;
    }
    for(Face f: faces) {
      f.render();
    }
  }

  Vec3D getPointVec() {
    return vecs.get(0).normalize();
  }

  void setSize(float size) {
    size = min(size, maxSize);
    for( Vec3D v : vecs ) {
      v.normalizeTo(size);
    }
  }
  void setOrigSize(float size) {
    origSize = size;
    setSize(size);
  }

  void scale(float size) {
    for( Vec3D v : vecs ) {
      v.scaleSelf(size);
    }
  }

  void rotate3D(Vec3D angle3D) {
    for( Vec3D vec : vecs ) {
      Vec3DHelper.rotate3D(vec, angle3D);
    }
  }

  void rotateTo(Vec3D v) {
    v = v.normalize();

    Vec3D point = getPointVec();
    Vec3D axis = Vec3DHelper.normalVector(point, v);
    test1 = point.scale(100);
    test2 = axis.scale(100);
    float angle = point.angleBetween(v);
    for( Vec3D vec : vecs ) {
      vec.rotateAroundAxis(axis, angle);
    }
  }

  void applyMatrix(float[][] m) {
    for( Vec3D v : vecs ) {
      Vec3DHelper.applyMatrix(v, m);
    }
  }
  
  void addFaces(ArrayList<Vec3D> vecs) {
    // TODO
    faces.add(new Face(vecs.get(0),
          vecs.get(1), vecs.get(2)));
    faces.add(new Face(vecs.get(0),
          vecs.get(1), vecs.get(3)));
    faces.add(new Face(vecs.get(0),
          vecs.get(3), vecs.get(2)));
    faces.add(new Face(vecs.get(3),
          vecs.get(1), vecs.get(2)));
  }

  void shapeJitter() {
    Vec3D center = new Vec3D();
    for(Vec3D v : vecs) {
      v.jitter(jitterSize);
      center.addSelf(v);
    }

    center.scaleSelf(1.0/vecs.size());
    for(Vec3D v : vecs) {
      v.addSelf(center.getInverted());
    }
  }

  void sizeJitter() {
    if (doSizeJitter()) {
      ccolor = changingColor;
      setSize(map(freqAmp, 0, 5.0, origSize, origSize * 2));
    } else {
      setSize(origSize);
      ccolor = normalColor;
    }
  }

  color[] colorArray = {ziggurat, neptune, bayoux, oxford, shark};

  color getColor() {
    if (theme == "black") {
      return blood;
    } else {
      int index = min(int(2 * origSize * colorArray.length / maxSize)
                      , colorArray.length - 1);
      return colorArray[index];
    }
  }

  Boolean doSizeJitter() {
    return freqAmp * sizeWeight + 10 > origSize
      && freqAmp * sizeWeight < maxSize;
  }

  void limitShape() {
    for(Vec3D v : vecs) {
      if (v.magnitude() < minSize) {
        v.normalizeTo(minSize);
      } else {
        v.limit(maxSize);
      }
    }
  }
}
