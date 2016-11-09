// var DialogForm = React.createClass({
//   id: 'dialog-form',

//   propTypes: {
//   },


//   render: function() {
//     return (
//       <form class='dialog' method='post' action='/dialogue_api/response'>

//         <hr class='margin5050'>

//         <div class='row'>
//           <strong class='two columns margin0'>Priority</strong>
//           <input name='priority' type='number' class='three columns priority-input'>
//           <br></br>
//           <br></br>
//         </div>

//         <hr class='margin-15'>

//         <div class='row'>
//           <strong class='two columns margin0'>Aneeda Says</strong>
//           <input class='aneeda-says two columns' name='response' type='text' placeholder='ex: Please log into your account' ><br>
//         </div>

//         <div class='aneeda-says-error'></div>
//         <hr class='margin0'>

//         <table class='dialog'>
//           <tr>
//             <td class='row16'>
//               <strong>is unresolved</strong>
//             </td>
//             <td class='row40'>
//               <%= select_tag(
//                 'unresolved-field',
//                 options_for_select( @fields ),
//                 { prompt:'', class: 'dialog-select' }
//               ) %>
//             </td>
//             <td></td>
//           </tr>

//           <tr>
//             <td class='row16'>
//               <strong>is missing</strong>
//             </td>
//             <td class='row40'>
//               <%= select_tag(
//                 'missing-field',
//                 options_for_select( @fields ),
//                 { prompt:'', class: 'dialog-select' }
//               ) %>
//             </td>
//             <td></td>
//           </tr>

//           <tr>
//             <td class='row16'>
//               <strong>is present</strong>
//             </td>
//             <td class='row40'>
//               <%= select_tag(
//                 'present-field',
//                 options_for_select( @fields ),
//                 { prompt:'', class: 'dialog-select' }
//               ) %>
//             </td>
//             <td>
//               <input class='dialog-input' name='present-value' type='text' placeholder='present value'>
//             </td>
//           </tr>
//         </table>

//         <div class='row'>
//           <strong class='two columns margin0'>Awaiting Field</strong>
//           <%= select_tag(
//             'awaiting-field',
//             options_for_select( @fields ),
//             { prompt:'', class: 'awaiting-dialog-select two columns' }
//           ) %>
//         </div>

//         <button class='btn lg ghost dialog-btn pull-right'>Create Dialog</button> &nbsp;
//       </form>
//     );
//   }
// });
