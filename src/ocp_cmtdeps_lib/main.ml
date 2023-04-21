(**************************************************************************)
(*                                                                        *)
(*  Copyright (c) 2021 OCamlPro SAS                                       *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*  This file is distributed under the terms of the GNU Lesser General    *)
(*  Public License version 2.1, with the special exception on linking     *)
(*  described in the LICENSE.md file in the root directory.               *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

open Ez_file.V1
open Cmt_format
open Cmi_format
open EzCompat
open EzFile.OP

let use_filenames = ref false

let graph = Ez_dot.V1.create "deps" []


type module_ = {
  name : string ;
  mutable filenames : string list ;
  node : Ez_toposort.V1.node ;
  mutable deps : module_ StringMap.t ;
  mutable dot : Ez_dot.V1.node option ;
}

module TOPOSORT = Ez_toposort.V1.MAKE(struct
    type t = module_
    let node t = t.node
    let iter_edges f t =
      StringMap.iter (fun _ t -> f t ) t.deps
    let name t = t.name
  end)

let modules = Hashtbl.create 111

let source_modules = ref []

let find_module modname =
  match Hashtbl.find modules modname with
  | exception Not_found ->
      let m = {
        name = modname ;
        filenames = [] ;
        node = Ez_toposort.V1.new_node () ;
        deps = StringMap.empty ;
        dot = None ;
      } in
      Hashtbl.add modules modname m ;
      m
  | m -> m

let main () =

  let format = ref "pdf" in
  let use_cmis = ref false in
  let all_links = ref false in
  let ignore_module = ref None in
  let remove_pack = ref None in
  let dirs = ref [] in
  let verbose = ref false in
  let summary = ref false in
  let basename = ref "deps" in
  Arg.parse
    [
      "--filenames", Arg.Set use_filenames,
      " Display filenames instead of modnames in deps.pdf";

      "--ignore-module", Arg.String (fun s -> ignore_module := Some s),
      "REGEXP Ignore modules matching REGEXP (glob kind)";

      "-X", Arg.String (fun s -> ignore_module := Some s),
      "REGEXP Ignore modules matching REGEXP (glob kind)";

      "--remove-pack", Arg.String (fun s -> remove_pack := Some s),
      "MODNAME Keep only modules within pack MODNAME, and display without prefix (MODNAME__)";

      "-R", Arg.String (fun s -> remove_pack := Some s),
      "MODNAME Keep only modules within pack MODNAME, and display without prefix (MODNAME__)";

      "--format", Arg.String (fun s -> format := s),
      "FORMAT Generate deps.FORMAT instead of deps.pdf (using FORMAT encoding)";

      "-T", Arg.String (fun s -> format := s),
      "FORMAT Generate deps.FORMAT instead of deps.pdf (using FORMAT encoding)";

      "--output", Arg.String (fun s -> basename := s),
      "BASENAME Name of file to generate (BASENAME.dot and BASENAME.FORMAT)";

      "-o", Arg.String (fun s -> basename := s),
      "BASENAME Name of file to generate (BASENAME.dot and BASENAME.FORMAT)";

      "--cmi", Arg.Set use_cmis, " Use .cmi files";
      "--all-links", Arg.Set all_links, " Keep all links";
      "-A", Arg.Set all_links, " Keep all links";

      "--text-summary", Arg.Set summary, " Print a text summary";
      "--verbose", Arg.Set verbose, " Verbose mode";
    ]
    (fun s ->
       dirs := s :: !dirs)
    "ocp-cmtdeps [OPTIONS] [SRCDIRS]: computes dependencies between compilation units from .cmt files found in SRCDIRS (or . if not specified)";

  let remove_prefix = match !remove_pack with
    | None -> None
    | Some modname -> Some ( modname, modname ^ "__" )
  in

  let globber ?pathname glob =
    let regexp = Re.Glob.glob ~anchored:true ?pathname glob in
    let re = Re.compile regexp in
    Re.execp re
  in
  let ignore_module = match !ignore_module with
    | None -> None
    | Some s -> Some (globber s)
  in

  (*
  let add_source ~dir filename =
    let filename = dir // filename in
    Printf.eprintf "Source: %S\n%!" filename ;
  in
*)
  let add_dep m name =
    if !verbose then
      Printf.eprintf "   add_dep %S\n%!" name;
    let name = match remove_prefix with
      | None -> name
      | Some (_packname, prefix) ->
          match EzString.chop_prefix ~prefix name with
          | Some name -> name
          | None -> name
    in
    if name <> m.name
    && EzString.chop_prefix ~prefix:( name ^ "__" ) m.name = None
    then
      m.deps <- StringMap.add name (find_module name) m.deps
  in

  let create_dot m filename =
    match m.dot with
    | Some _ -> ()
    | None ->
        m.dot <- Some ( Ez_dot.V1.node graph
                          (if !use_filenames then
                             filename
                           else
                             m.name ) [] );
        m.filenames <- filename :: m.filenames ;
        source_modules := m :: !source_modules
  in

  let check_modname modname ~filename f =
    let check_modname modname =
      let m = find_module modname in
      f m
    in
    let check_modname modname =
      match ignore_module with
      | None -> check_modname modname
      | Some ignore_module ->
          if
            ignore_module modname
          then
            Printf.eprintf "Ignored module %S in %S\n%!"
              modname filename
          else
            check_modname modname
    in
    let check_modname modname =
      match remove_prefix with
      | None -> check_modname modname
      | Some (_name, prefix) ->
          match EzString.chop_prefix ~prefix modname with
          | Some modname -> check_modname modname
          | None -> ()
    in

    check_modname modname
  in
  let add_object ~dir filename =
    let filename = dir // filename in
    if !verbose then
      Printf.eprintf "Binary: %S\n%!" filename ;
    let cmi, cmt = Cmt_format.read filename in
    begin
      match cmt with
      | Some cmt ->
          check_modname ~filename cmt.cmt_modname
            (fun m ->
               begin
                 match cmt.cmt_sourcefile with
                 | None -> ()
                 | Some filename ->
                     create_dot m filename
               end;
               List.iter (fun (name, _crc_opt) -> add_dep m name) cmt.cmt_imports ;
            )
      | None ->
          match cmi with
          | None -> ()
          | Some cmi ->
              if !use_cmis then
                check_modname ~filename cmi.cmi_name (fun m ->
                    create_dot m filename ;
                    List.iter (fun (name, _crc_opt) ->
                        add_dep m name
                      ) cmi.cmi_crcs ;
                  )

    end
  in
  let dirs = match !dirs with
      [] -> [ "." ]
    | dirs -> List.rev dirs
  in
  let obj_glob =
    let glob = if !use_cmis then "*.cmi" else "*.cmt*" in
    globber glob
  in
  let iter dir =
    let rec iter dirname =
      let files = try Sys.readdir (dir // dirname)
        with _ ->
          Printf.eprintf "Warning: cannot read %S\n%!" ( dir // dirname ) ;
          [||]
      in
      Array.iter (fun file ->
          let filename = dirname // file in
          if obj_glob file then
            add_object ~dir filename
          else
          if file <> "_opam" &&
             try Sys.is_directory (dir // filename ) with _ -> false
          then
            iter filename
        ) files
    in
    iter "."
  in
  List.iter iter dirs ;
(*
  let obj_select = EzFile.select ~deep:true ~glob ~ignore:"_*" () in
  let src_select = EzFile.select ~deep:true ~glob:"*.ml*" ~ignore:"_*" () in
  List.iter (fun dir ->
      EzFile.iter_dir ~f:(add_object ~dir) ~select:obj_select dir ) dirs ;
  List.iter (fun dir ->
      EzFile.iter_dir ~f:(add_source ~dir) ~select: src_select dir ) dirs ;
*)

  let ( sorted, cycles, _others ) = TOPOSORT.sort !source_modules in

  List.iter (fun ( m, _incoming, _outgoing ) ->
      Printf.eprintf "Cycle: %s\n%!" m.name;
    ) cycles ;

  if not !all_links then
    List.iter (fun m ->
        StringMap.iter (fun _ m2 ->
            match m2.dot with
            | None -> ()
            | Some _ ->
                StringMap.iter (fun name _ ->
                    if StringMap.mem name m.deps then
                      m.deps <- StringMap.remove name m.deps
                  ) m2.deps
          ) m.deps ;
      ) ( List.rev sorted ) ;

  let nedges = ref 0 in
  List.iter (fun m ->
      match m.dot with
      | None -> ()
      | Some dot ->
          if !summary then
            Printf.printf "%s\n    deps: " m.name ;
          StringMap.iter (fun _ m2 ->
              match m2.dot with
              | None -> ()
              | Some dot2 ->
                  Ez_dot.V1.add_edge dot dot2 [];
                  incr nedges ;
                  if !summary then
                    Printf.printf "%s " m2.name ;
            ) m.deps ;
          if !summary then
            Printf.printf "\n" ;
          List.iter (fun filename ->
              if !summary then
                Printf.printf "    file: %s\n%!" filename
            ) m.filenames ;

    ) sorted ;

  let dotfile = !basename ^ ".dot" in
  Ez_dot.V1.save graph dotfile ;
  let outfile = !basename ^ "." ^ !format in
  Ez_dot.V1.dot2file ~dotfile ~format:!format ~outfile;
  Printf.eprintf "Generated %d edges in %S and %S\n%!"
    !nedges dotfile outfile;
  ()
