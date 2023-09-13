using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour {

	public bool CanMove = true;
	public bool CanMoveForward = true;
	public bool CanMoveBack = true;
	public bool CanMoveLeft = true;
	public bool CanMoveRight = true;
	public bool CanMoveUp = true;
	public bool CanMoveDown = true;
	public bool CanRotateYaw = true;
	public bool CanRotatePitch = true;
	public bool CanRotateRoll = true;

	public float MovementSpeed = 30f;
	public float RotationSpeed = 0.01f;

	private bool canTranslate;
	private bool canRotate;

	void Start() {
		canTranslate = CanRotateYaw || CanRotatePitch || CanRotateRoll;
		canRotate = CanMoveForward || CanMoveBack || CanMoveRight || CanMoveLeft || CanMoveUp || CanMoveDown;
	}
	
	void Update() {
		// 前進は自動
        transform.Translate(0f, 0f, 50f * Time.deltaTime);
	}

	void FixedUpdate() {
		if( CanMove ) {
			UpdatePosition();
		}
	}

	void UpdatePosition() {
		// Rotation
		if( canRotate ) {
			Quaternion AddRot = Quaternion.identity;
			float yaw = 0;
			float pitch = 0;
			float roll = 0;
			if( CanRotateYaw ) {
				yaw = Input.GetAxis( "Yaw" ) * ( Time.deltaTime * RotationSpeed );
			}
			if( CanRotatePitch ){
				pitch = Input.GetAxis( "Pitch" ) * ( Time.deltaTime * RotationSpeed );
			}
			if( CanRotateRoll ){
				roll = Input.GetAxis( "Roll" ) * ( Time.deltaTime * RotationSpeed );
			}
			AddRot.eulerAngles = new Vector3( -pitch, yaw, 0);
			GetComponent<Rigidbody>().rotation *= AddRot;
		}
		//ブースト
		// if(Input.GetAxis("Fire")){
		// 	transform.Translate(0f,0f,100f);
		// }


	}

}