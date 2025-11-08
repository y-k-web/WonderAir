using UnityEngine;

namespace RageRunGames.EasyFlyingSystem
{
    /// <summary>
    /// Handles two dimensional input for touch/joystick based controls.
    /// Provides a common access point that can be shared with animator and debug helpers.
    /// </summary>
    [DisallowMultipleComponent]
    public class MobileController : MonoBehaviour
    {
        [SerializeField]
        private bool useUnityInputFallback = true;

        private Vector2 baseInput;
        private Vector2 debugContribution;

        /// <summary>
        /// Determines whether the legacy Unity input axes should be sampled when no other input provider is used.
        /// </summary>
        public bool UseUnityInputFallback
        {
            get => useUnityInputFallback;
            set => useUnityInputFallback = value;
        }

        /// <summary>
        /// Current input vector after combining base input and debug contribution.
        /// </summary>
        public Vector2 CurrentInput => Vector2.ClampMagnitude(baseInput + debugContribution, 1f);

        /// <summary>
        /// Horizontal input component. Convenience accessor for animator controllers.
        /// </summary>
        public float Horizontal => CurrentInput.x;

        /// <summary>
        /// Vertical input component. Convenience accessor for animator controllers.
        /// </summary>
        public float Vertical => CurrentInput.y;

        private void Update()
        {
            if (useUnityInputFallback)
            {
                SetBaseInput(new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical")));
            }
        }

        /// <summary>
        /// Sets the primary input vector, typically coming from on screen joystick or new input system callbacks.
        /// The value will be clamped to a unit circle.
        /// </summary>
        /// <param name="value">The desired base input value.</param>
        public void SetBaseInput(Vector2 value)
        {
            baseInput = Vector2.ClampMagnitude(value, 1f);
        }

        /// <summary>
        /// Allows debug systems to override the combined input. The method stores only the delta contribution
        /// so repeated calls using <see cref="CurrentInput"/> remain stable.
        /// </summary>
        /// <param name="combined">Combined input that should become the current value.</param>
        public void SetDebugInput(Vector2 combined)
        {
            Vector2 clamped = Vector2.ClampMagnitude(combined, 1f);
            debugContribution = clamped - baseInput;
        }

        /// <summary>
        /// Resets any debug influence previously applied by <see cref="SetDebugInput"/>.
        /// </summary>
        public void ClearDebugInput()
        {
            debugContribution = Vector2.zero;
        }
    }
}
