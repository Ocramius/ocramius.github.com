"use strict";
var mario = (function (marioDir) {
    var container,
        $container,
        renderer,
        camera,
        scene,
        shield,
        marios = [],
        currentMario = 0,
        MARIO_COUNT = 12;

    function initMario() {
        init();
        animate();

        function deg2rad(deg) {
            return deg * (Math.PI / 180);
        }

        function init() {
            var VIEW_ANGLE = 45,
                NEAR = 0.1,
                FAR = 10000;

            $container = $('#shield-container');
            renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
            renderer.setClearColor( 0x000000, 0 );
            camera = new THREE.PerspectiveCamera(VIEW_ANGLE, $container.width() / $container.height(), NEAR, FAR);
            scene = new THREE.Scene();
            scene.add(camera);
            camera.position.x = 30;
            camera.position.y = 300;
            renderer.setSize($container.width(), $container.height());
            $container.append(renderer.domElement);

            var pointLight = new THREE.PointLight(0xFFFFFF);

            pointLight.position.x = 50;
            pointLight.position.y = 200;
            pointLight.position.z = 30;

            scene.add(pointLight);

            var texture = THREE.ImageUtils.loadTexture(marioDir + "/mario_tex.png");

            for (var i = 0; i < MARIO_COUNT; i += 1) {
                // encapsulating in a closure to avoid scope leakages on the iterator value
                (function (i) {
                    (new THREE.OBJLoader())
                        .load(marioDir + "/Frame_" + (i + 1) + ".obj", function(geometries) {
                            var material = new THREE.MeshLambertMaterial({map: texture});
                            shield       = new THREE.Mesh(geometries.children[0].geometry, material);

                            shield.rotation.y = deg2rad(90);
                            shield.scale.set(10, 10, 10);
                            scene.add(shield);
                            shield.geometry.applyMatrix(new THREE.Matrix4().makeTranslation(1.1, 0.5, 0));
                            shield.geometry.verticesNeedUpdate = true;
                            shield.visible = false;

                            marios[i] = shield;
                        });
                }(i));
            }
        }

        function render() {
            camera.lookAt( scene.position );

            renderer.render( scene, camera );
        }

        function animate() {
            requestAnimationFrame(animate);
            currentMario += 0.2;
            var currentMarioIndex = parseInt(currentMario) % MARIO_COUNT;

            for (var i = 0; i < marios.length; i += 1) {
                marios[i].visible = (i === currentMarioIndex);

                marios[i].rotation.z += deg2rad(2);

                if (marios[i].rotation.z > 2 * Math.PI) {
                    marios[i].rotation.z = 0;
                }
            }

            render();
        }
    }

    initMario();
});
