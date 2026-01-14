use std::ptr;
use std::mem;

#[repr(C)]
struct Hook {
    original_addr: *mut u8,
    target_addr: *mut u8,
    original_bytes: [u8; 12],
}

impl Hook {
    unsafe fn apply(&mut self) {
        ptr::copy_nonoverlapping(self.original_addr, self.original_bytes.as_mut_ptr(), 12);
        let mut patch = [0u8; 12];
        patch[0] = 0x48;
        patch[1] = 0xB8;
        let addr_bytes: [u8; 8] = mem::transmute(self.target_addr);
        patch[2..10].copy_from_slice(&addr_bytes);
        patch[10] = 0xFF;
        patch[11] = 0xE0;
        
        ptr::copy_nonoverlapping(patch.as_ptr(), self.original_addr, 12);
    }

    unsafe fn restore(&self) {
        ptr::copy_nonoverlapping(self.original_bytes.as_ptr(), self.original_addr, 12);
    }
}

fn main() {
    println!("Hooking engine initialized.");
}
