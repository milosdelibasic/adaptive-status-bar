import UIKit

let strip = CGRect(x: 0, y: 0, width: 402, height: 62)
let screen = CGRect(x: 0, y: 0, width: 402, height: 874)
var passed = 0

func check(_ name: String, _ expected: Bool, _ configure: (CALayer) -> Void) {
  let root = CALayer()
  root.frame = screen
  configure(root)
  precondition(StripRenderer.requiresHierarchy(root, strip: strip) == expected, name)
  passed += 1
}

func gpu(_ frame: CGRect = screen) -> CALayer {
  let layer = CAMetalLayer()
  layer.frame = frame
  return layer
}

check("ordinary UI stays on cheap layer capture", false) { root in
  root.backgroundColor = UIColor.white.cgColor
}
check("visible Metal beneath status bar selects hierarchy", true) { $0.addSublayer(gpu()) }
check("hidden Metal is ignored", false) { root in
  let metal = gpu(); metal.isHidden = true; root.addSublayer(metal)
}
check("transparent Metal is ignored", false) { root in
  let metal = gpu(); metal.opacity = 0; root.addSublayer(metal)
}
check("Metal below status bar is ignored", false) { root in
  root.addSublayer(gpu(CGRect(x: 0, y: 100, width: 402, height: 500)))
}
check("opaque foreground prevents unnecessary GPU capture", false) { root in
  root.addSublayer(gpu())
  let cover = CALayer(); cover.frame = strip; cover.backgroundColor = UIColor.white.cgColor
  root.addSublayer(cover)
}
check("translucent foreground still samples Metal behind it", true) { root in
  root.addSublayer(gpu())
  let cover = CALayer(); cover.frame = strip; cover.backgroundColor = UIColor.white.cgColor; cover.opacity = 0.5
  root.addSublayer(cover)
}
check("zIndex determines occlusion, not array order", false) { root in
  let cover = CALayer(); cover.frame = strip; cover.backgroundColor = UIColor.white.cgColor; cover.zPosition = 2
  root.addSublayer(cover); root.addSublayer(gpu())
}
check("hidden parent hides GPU children", false) { root in
  let parent = CALayer(); parent.frame = screen; parent.isHidden = true
  parent.addSublayer(gpu()); root.addSublayer(parent)
}
check("clipped parent outside strip hides overflowing GPU", false) { root in
  let parent = CALayer(); parent.frame = CGRect(x: 0, y: 100, width: 402, height: 500); parent.masksToBounds = true
  parent.addSublayer(gpu(CGRect(x: 0, y: -100, width: 402, height: 500))); root.addSublayer(parent)
}
check("unclipped overflow can still reach status bar", true) { root in
  let parent = CALayer(); parent.frame = CGRect(x: 0, y: 100, width: 402, height: 500)
  parent.addSublayer(gpu(CGRect(x: 0, y: -100, width: 402, height: 500))); root.addSublayer(parent)
}
check("translated GPU uses on-screen coordinates", false) { root in
  let metal = gpu(strip); metal.setAffineTransform(CGAffineTransform(translationX: 0, y: 200))
  root.addSublayer(metal)
}
check("3D GPU transforms use hierarchy rather than dropping content", true) { root in
  let metal = gpu(); metal.transform = CATransform3DMakeRotation(0.2, 1, 0, 0); root.addSublayer(metal)
}
print("Passed \(passed) native strip capture policy checks")
